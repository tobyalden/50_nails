package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Player extends Entity
{
    public static inline var SPEED = 100;
    public static inline var SHOT_COOLDOWN = 0.1;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var shotCooldown:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(10, 10);
        sprite = new Spritemap("graphics/player.png", 10, 10);
        sprite.add("idle", [0]);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2();
        shotCooldown = new Alarm(SHOT_COOLDOWN);
        addTween(shotCooldown);
    }

    override public function update() {
        combat();
        var heading = new Vector2();
        if(Input.check("left")) {
            heading.x = -1;
            sprite.flipX = true;
        }
        else if(Input.check("right")) {
            heading.x = 1;
            sprite.flipX = false;
        }
        else {
            heading.x = 0;
        }
        if(Input.check("up")) {
            heading.y = -1;
        }
        else if(Input.check("down")) {
            heading.y = 1;
        }
        else {
            heading.y = 0;
        }
        velocity = heading;
        velocity.normalize(SPEED);
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls"]);
        super.update();
    }

    private function combat() {
        if(Input.pressed("shoot")) {
            // Scatter shot
            var nailCount = 10;
            var angle = Math.PI / 6;
            for(i in 0...nailCount) {
                var angle = (
                    (sprite.flipX ? -Math.PI / 2: Math.PI / 2)
                    + i * (angle / (nailCount - 1))
                    - angle / 2
                );
                trace(angle);
                var nail = new Nail(
                    centerX, centerY,
                    {
                        angle: angle,
                        speed: 500 + 200 * Math.random()
                    }
                );
                HXP.scene.add(nail);
            }
            shotCooldown.start();
        }
        if(Input.check("shoot") && !shotCooldown.active) {
            // Rapid fire
            var nail = new Nail(
                centerX, centerY,
                {
                    angle: sprite.flipX ? -Math.PI / 2: Math.PI / 2,
                    speed: 500,
                }
            );
            HXP.scene.add(nail);
            shotCooldown.start();
        }
    }
}
