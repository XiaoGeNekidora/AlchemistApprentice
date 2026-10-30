# Item rendering checks

From the project root, using the Godot 4.7 executable:

```sh
godot --headless --path . res://tests/item_rendering_test.tscn
```

The 90 checks cover both presentation modes, binary types, recursive layout, ingredient ordering, small-detail
collapse, resize-driven detail expansion, missing textures, nested corruption and
mold opacity, actor count, hover animation, tooltip layout, and hand spacing.

To also render a gallery and check actual GPU output (94 checks total):

```sh
godot --path . res://tests/item_rendering_test.tscn -- --gallery=/tmp/items.png
```

`ItemRenderer` compiles the visible item tree into cached drawing commands on item
or size changes. `_draw()` only submits those commands. The default `ITEM` mode
keeps the original object sprite underneath two half-size ingredients, at the
upper-right and lower-right. Nested ingredients use the same right-side arrangement,
without frames, backgrounds, connectors, or ellipsis badges. Hand layout uses
five columns and an 84px `CELL_SPACING` for both axes, leaving room for hover motion.

Only the tooltip opts into `STRUCTURE` mode: a type icon above equally sized
ingredients, with an arrow, plus, or logical OR symbol between them. Small details
collapse to a type icon and ellipsis, while the larger inspection view exposes
more levels. Neither presentation creates nodes for individual ingredients.
