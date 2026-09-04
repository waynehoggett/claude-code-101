# Produces what a learner leaves behind after task 3: a ledger repo with a delete
# feature committed, a CLAUDE.md that demands tests, and a rename feature committed
# with tests. Both features are implemented for real so the suite passes.
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$ClaudeHome,
    [ValidateSet('py', 'js')][string]$Language = 'py',
    [string]$SourceRepo = "https://github.com/waynehoggett/ledger-$Language"
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $Workspace -Force | Out-Null

$repo = "$Workspace/ledger-$Language"
git clone --quiet $SourceRepo $repo
if ($LASTEXITCODE -ne 0) { throw "Could not clone $SourceRepo." }
git -C $repo config user.name 'Workshop Learner'
git -C $repo config user.email 'learner@example.com'

function Write-Text([string]$path, [string]$text) {
    [IO.File]::WriteAllText($path, $text.Replace("`r`n", "`n"))
}
function Commit([string]$message) {
    git -C $repo add -A
    git -C $repo commit --quiet -m $message
    if ($LASTEXITCODE -ne 0) { throw "Commit failed: $message" }
}

if ($Language -eq 'py') {
    $store = "$repo/src/ledger/store.py"
    $src = Get-Content $store -Raw
    $src = $src.Replace("from typing import Dict, List", "from dataclasses import replace`nfrom typing import Dict, List")
    $src = $src.TrimEnd() + @'


    def delete(self, transaction_id: str) -> Result[Transaction]:
        tx = self._items.pop(transaction_id, None)
        if tx is None:
            return err(f"no transaction with id {transaction_id!r}")
        return ok(tx)
'@ + "`n"
    Write-Text $store $src

    $deleteTests = @'
import unittest

from ledger import Store


class StoreDeleteTests(unittest.TestCase):
    def setUp(self):
        self.store = Store()
        self.tx = self.store.add("Coffee", "food", 3.5).value

    def test_delete_existing_removes_it(self):
        result = self.store.delete(self.tx.id)
        self.assertTrue(result.is_ok)
        self.assertEqual(len(self.store), 0)

    def test_delete_missing_is_err(self):
        result = self.store.delete("t999")
        self.assertTrue(result.is_err)
        self.assertIn("t999", result.error)
'@
    Write-Text "$repo/tests/test_store_features.py" ($deleteTests + "`n")
    Commit "Add support for deleting a transaction"

    Write-Text "$repo/CLAUDE.md" "# Rules`n`nEvery code change must include tests that prove it works.`n"

    $src = (Get-Content $store -Raw).TrimEnd() + @'


    def rename_category(self, old: str, new: str) -> Result[int]:
        old = old.strip().lower()
        new = new.strip().lower()
        if not new:
            return err("category must not be empty")
        renamed = 0
        for tx_id, tx in list(self._items.items()):
            if tx.category == old:
                self._items[tx_id] = replace(tx, category=new)
                renamed += 1
        if renamed == 0:
            return err(f"no transactions in category {old!r}")
        return ok(renamed)
'@ + "`n"
    Write-Text $store $src

    $renameTests = @'


class StoreRenameCategoryTests(unittest.TestCase):
    def setUp(self):
        self.store = Store()
        self.store.add("Coffee", "food", 3.5)
        self.store.add("Bus", "transport", 2.75)

    def test_rename_updates_every_match(self):
        result = self.store.rename_category("food", "groceries")
        self.assertTrue(result.is_ok)
        self.assertEqual(result.value, 1)
        categories = [tx.category for tx in self.store.list_all()]
        self.assertEqual(categories, ["groceries", "transport"])

    def test_rename_unknown_category_is_err(self):
        result = self.store.rename_category("fun", "leisure")
        self.assertTrue(result.is_err)
'@
    Write-Text "$repo/tests/test_store_features.py" ($deleteTests + $renameTests + "`n")
    Commit "Add support for renaming a category"
}
else {
    $store = "$repo/src/ledger/store.js"
    $src = Get-Content $store -Raw
    $src = $src.Replace("    get size() {", @'
    delete(id) {
      return items.delete(id);
    },

    get size() {
'@)
    Write-Text $store $src

    $deleteTests = @'
import { test, describe } from 'node:test';
import assert from 'node:assert/strict';

import { createStore, ValidationError } from '../src/ledger/index.js';

describe('store.delete', () => {
  test('removes an existing transaction', () => {
    const store = createStore();
    const tx = store.add('Coffee', 'food', 3.5);
    assert.equal(store.delete(tx.id), true);
    assert.equal(store.size, 0);
  });

  test('returns false for an unknown id', () => {
    assert.equal(createStore().delete('t999'), false);
  });
});
'@
    Write-Text "$repo/test/store-features.test.js" ($deleteTests + "`n")
    Commit "Add support for deleting a transaction"

    Write-Text "$repo/CLAUDE.md" "# Rules`n`nEvery code change must include tests that prove it works.`n"

    $src = (Get-Content $store -Raw).Replace("    get size() {", @'
    renameCategory(from, to) {
      const source = String(from).trim().toLowerCase();
      if (typeof to !== 'string' || to.trim() === '') {
        throw new ValidationError('category must not be empty');
      }
      let renamed = 0;
      for (const [id, tx] of items) {
        if (tx.category === source) {
          items.set(id, makeTransaction({ ...tx, category: to }));
          renamed += 1;
        }
      }
      return renamed;
    },

    get size() {
'@)
    Write-Text $store $src

    $renameTests = @'

describe('store.renameCategory', () => {
  test('renames every transaction in the category', () => {
    const store = createStore();
    store.add('Coffee', 'food', 3.5);
    store.add('Bus', 'transport', 2.75);
    assert.equal(store.renameCategory('food', 'groceries'), 1);
    assert.deepEqual(store.list().map((t) => t.category), ['groceries', 'transport']);
  });

  test('rejects an empty new name', () => {
    const store = createStore();
    store.add('Coffee', 'food', 3.5);
    assert.throws(() => store.renameCategory('food', ' '), ValidationError);
  });
});
'@
    Write-Text "$repo/test/store-features.test.js" ($deleteTests + $renameTests + "`n")
    Commit "Add support for renaming a category"
}
