@{
    # Failure messages the grader must give for a given sabotage script. Keys are
    # check names; values are patterns the failure message must match.
    SabotageMessages = @{
        'sabotage-hand-edit.ps1' = @{
            'Claude picked the skill itself from a plain request' = 'by hand.*/clear'
        }
    }
}
