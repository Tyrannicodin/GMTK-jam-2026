# Template Game

This is a template for our team.


## Testing specific parts of the code
To test a specific part of the code, you can run a gdscrpit file in the tests folder.
For example to open the game scene directly:
```
godot -s tests/start_game.gd
```

These gdscript files have a function called 'setup' to allow you to, well, setup the scene.
For example, if you wanted to start a player with certain cards in a card game, you should put the code to
do that in that function.

To write test that stay on your local system name the file `tests/<your_test_name>.local.gd`.
