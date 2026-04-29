Project uses Entity Component System architecture (ECS).

Content made so far:
- Fully modular item system allowing the player to pick items up and store them in their inventory.
- Each item has its own "item_data" resource which stores its size in the inventory grid (similar to Resident Evil 4) as well as its name.
- Guns can be equipped and fired with each gun having its own bullet_component resource inheriting from one gun.gd script allowing for fully modular weapon design.
- Health system allows entities with a health component to take damage and heal when an event is triggered.
- More I've probably forgotten to mention.
