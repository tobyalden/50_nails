package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Nail extends Entity
{
    public static inline var GRAVITY = 600;

    public var hasFired(default, null):Bool;
    public var hasCollided(default, null):Bool;
    private var velocity:Vector2;
    private var sprite:Image;
    private var angle:Float;
    private var speed:Float;
    private var spinSpeed:Float;

    public function new() {
        super();
        layer = 10;
        type = "nail";
        angle = 0;
        speed = 0;
        mask = new Hitbox(2, 2);
        sprite = new Image("graphics/nail.png");
        sprite.centerOrigin();
        sprite.x = 3 - 2;
        sprite.y = 1;
        graphic = sprite;
        velocity = new Vector2();
        hasFired = false;
        hasCollided = false;
        spinSpeed = 0;
    }

    public function fire(position:Vector2, speed:Float, angle:Float) {
        moveTo(position.x, position.y);
        this.speed = speed;
        this.angle = angle;
        hasFired = true;
    }

    public function collect() {
        hasFired = false;
        hasCollided = false;
        sprite.angle = 0;
    }

    override public function update() {
        visible = hasFired;
        collidable = hasFired;
        if(!hasFired) {
            return;
        }
        if(hasCollided) {
            if(velocity.length < 10) {
                velocity.x = 0;
                velocity.y = 0;
            }
            else {
                sprite.angle += spinSpeed;
                velocity.y += GRAVITY * HXP.elapsed;
            }
        }
        else {
            velocity.x = Math.cos(angle);
            velocity.y = Math.sin(angle);
            velocity.normalize(speed);
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        onCollision();
        velocity.x = -velocity.x / 4;
        velocity.y = -40;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        onCollision();
        velocity.x = velocity.x / 2;
        velocity.y = -velocity.y / 4;
        return true;
    }

    public function onCollision() {
        if(!hasCollided) {
            HXP.tween(sprite, {"alpha": 0.75}, 1);
        }
        hasCollided = true;
        spinSpeed = 10 + Math.random() * 20;
        if(velocity.x < 0) {
            spinSpeed = -spinSpeed;
        }
    }
}

