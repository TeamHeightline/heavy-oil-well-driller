# Oil Well Drilling Vehicle

Oil drilling vehicle with separate travel and drilling poses. Drills an existing crude-oil deposit and installs a normal pumpjack supplied from the trunk.

**100% vibe-coded with Codex (OpenAI): all mod code was created with AI under the author’s direction. The 3D models were generated with Tripo AI.**

![Oil Well Drilling Vehicle](docs/preview.png)

[Подробный README на русском](README.md)

Version **0.4.0**, Factorio 2.0. Standalone; Space Age is optional. Unlocks with **Railway**, alongside the locomotive, using red and green science.

## Recipe

- `steel-plate`: 80
- `iron-gear-wheel`: 40
- `engine-unit`: 20
- `electronic-circuit`: 30
- `pipe`: 50

Craft time: 45 seconds. Produces one vehicle. Optional Heavy Construction Machinery Plant compatibility keeps the same recipe and unlock.

## Controls and behaviour

W accelerates, S brakes/reverses, A/D steer. Open the vehicle GUI to change its tool mode. Uses chemical fuel such as coal.

Supply one pumpjack and 10 pipes in the trunk, then align the head over an existing crude-oil deposit. Enabling drilling instantly deploys the work pose and locks both driving and turning, even while waiting for fuel/materials. Disable the mode to move again; unfinished work is reset. Thirty seconds at 2.4 MW installs the supplied pumpjack; connect power and pipes. Materials are consumed only after successful placement. Completion automatically restores travel mode. Does not create oil deposits or increase resources. Pumpjack crafting still requires Oil processing.

## Graphics and development

Original model materials, orthographic 45-degree camera, soft diffuse lighting, 128 fixed-scale views, animated tracks/tools and separate shadows. Models generated with Tripo AI; rendered in Blender. Existing vehicles survive updates and recipe unlocks are resynchronised to Railway.

No in-game tests were run for this release at the author's request. Please include Factorio/mod versions, other enabled mods, reproduction steps and the relevant log excerpt when reporting a bug.

Concept, direction and in-game review: artel. All mod code: 100% vibe coding with Codex (OpenAI). 3D generation: Tripo AI. Unofficial Factorio mod; not a Wube Software product.
