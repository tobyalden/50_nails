package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

typedef NailOptions = {
    var width:Int;
    var height:Int;
    var angle:Float;
    var speed:Float;
    @:optional var callback:Nail->Void;
    @:optional var callbackDelay:Float;
    @:optional var color:Int;
}

class Nail extends Entity
{
    public static inline var GRAVITY = 600;

    public var velocity:Vector2;
    public var sprite:Image;
    public var angle:Float;
    public var speed:Float;
    public var nailOptions:NailOptions;
    public var hasCollided:Bool;
    public var spinSpeed:Float;

    public function new(x:Float, y:Float, nailOptions:NailOptions) {
        super(x - nailOptions.width / 2, y - nailOptions.height / 2);
        layer = 10;
        this.nailOptions = nailOptions;
        type = "nail";
        this.angle = nailOptions.angle - Math.PI / 2;
        this.speed = nailOptions.speed;
        mask = new Hitbox(2, 2);
        var color = nailOptions.color == null ? 0xFFFFFF : nailOptions.color;
        sprite = new Image("graphics/nail.png");
        sprite.centerOrigin();
        sprite.x = 3 - 2;
        sprite.y = 1;
        sprite.color = color;
        graphic = sprite;
        velocity = new Vector2();
        var callbackDelay = (
            nailOptions.callbackDelay == null ? 0 : nailOptions.callbackDelay
        );
        if(nailOptions.callback != null) {
            addTween(new Alarm(callbackDelay, function() {
                nailOptions.callback(this);
            }), true);
        }
        hasCollided = false;
        spinSpeed = 0;
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

    override public function update() {
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
}

