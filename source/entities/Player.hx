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
    public static inline var RAPID_COOLDOWN = 0.1;
    public static inline var SCATTER_COOLDOWN = 1;
    public static inline var SCATTER_COUNT = 10;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var rapidCooldown:Alarm;
    private var scatterCooldown:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        mask = new Hitbox(10, 10);
        sprite = new Spritemap("graphics/player.png", 10, 10);
        sprite.add("idle", [0]);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2();
        rapidCooldown = new Alarm(RAPID_COOLDOWN);
        addTween(rapidCooldown);
        scatterCooldown = new Alarm(SCATTER_COOLDOWN);
        addTween(scatterCooldown);
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
        //if(Input.pressed("shoot") && !scatterCooldown.active) {
        if(Input.pressed("shoot")) {
            // Scatter shot
            var angle = Math.PI / 6;
            var shotCount = SCATTER_COUNT;
            if(scatterCooldown.active) {
                shotCount = Std.int(Math.floor(SCATTER_COUNT * scatterCooldown.percent) / 2);
            }
            for(i in 0...shotCount) {
                var angle = (
                    (sprite.flipX ? -Math.PI / 2: Math.PI / 2)
                    + i * (angle / (shotCount - 1))
                    - angle / 2
                );
                var nail = new Nail(
                    centerX, centerY,
                    {
                        angle: angle,
                        speed: 500 + 200 * Math.random()
                    }
                );
                HXP.scene.add(nail);
            }
            scatterCooldown.start();
        }
        if(Input.check("shoot") && !rapidCooldown.active) {
            // Rapid fire
            var nail = new Nail(
                centerX, centerY,
                {
                    angle: sprite.flipX ? -Math.PI / 2: Math.PI / 2,
                    speed: 500,
                }
            );
            HXP.scene.add(nail);
            rapidCooldown.start();
            scatterCooldown.start();
        }
    }
}
