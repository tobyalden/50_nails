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
    public static inline var SCATTER_COOLDOWN = 0.5;
    public static inline var SCATTER_COUNT = 8;
    public static inline var RAPID_COOLDOWN = SCATTER_COOLDOWN / SCATTER_COUNT;

    public var nails(default, null):Array<Nail>;
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var rapidCooldown:Alarm;
    private var scatterCooldown:Alarm;
    private var shotBuffered:Bool;
    private var age:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        nails = [for (i in 0...50) new Nail()];
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
        shotBuffered = false;
        age = 0;
    }

    override public function update() {
        movement();
        combat();
        collisions();
        var nailCount = 0;
        for(nail in nails) {
            if(nail.hasFired) {
                continue;
            }
            nail.moveTo(centerX, centerY);
            var revolveSpeed = 2;
            var nailSeparation = MathUtil.lerp(2, 0, nailCount / nails.length);
            nail.sprite.x = Math.cos((age + nailSeparation) * revolveSpeed) * 20;
            nail.sprite.y = Math.sin((age + nailSeparation) * 2 * revolveSpeed) * 10;
            if(nail.sprite.x > 15) {
                nail.layer = -10;
            }
            else if(nail.sprite.x < -15) {
                nail.layer = 10;
            }
            nailCount++;
        }
        age += HXP.elapsed;
        super.update();
    }

    private function movement() {
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
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls"]
        );
    }


    private function combat() {
        if(
            Main.tapped("shoot", 5)
            && scatterCooldown.active
            && scatterCooldown.percent > 0.7
        ) {
            shotBuffered = true;
        }
        if(
            (Main.tapped("shoot", 5) || shotBuffered)
            && !scatterCooldown.active
        )
         {
            // Scatter shot
            var angle = Math.PI / 6;
            var shotCount = SCATTER_COUNT;
            for(i in 0...shotCount) {
                var angle = (
                    (sprite.flipX ? -Math.PI: 0)
                    + i * (angle / (shotCount - 1))
                    - angle / 2
                );
                fireNail(500, angle);
            }
            scatterCooldown.start();
            shotBuffered = false;
        }
        if(Main.held("shoot", 6) && !rapidCooldown.active) {
            // Rapid fire
            var angle = sprite.flipX ? -Math.PI: 0;
            fireNail(500, angle);
            rapidCooldown.start();
        }
    }

    private function fireNail(speed:Float, angle:Float) {
        for(nail in nails) {
            if(!nail.hasFired) {
                nail.fire(
                    new Vector2(centerX - 4, centerY - 2),
                    speed,
                    angle
                );
                break;
            }
        }
    }

    private function collisions() {
        var nails = [];
        collideInto("nail", x, y, nails);
        for(_nail in nails) {
            var nail = cast(_nail, Nail);
            if(nail.hasFired && nail.hasCollided) {
                nail.collect();
            }
        }
    }
}
