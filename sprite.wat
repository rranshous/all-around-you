(module
    (global $cnvs_size (import "env" "cnvs_size") i32)
    (global $img_buf_size (import "env" "img_buf_size") i32)
    (import "env" "buffer" (memory 1))

(global $yval (mut i32) (i32.const 60))

  (;
    0 0 1 1 1 1 0 0         0x3c
    0 1 0 0 0 0 1 0         0x42
    1 0 1 0 0 1 0 1         0xa5
    1 0 0 0 0 0 0 1         0x81
    1 0 1 0 0 1 0 1         0xa5
    1 0 0 1 1 0 0 1         0x99
    0 1 0 0 0 0 1 0         0x42
    0 0 1 1 1 1 0 0         0x3c
  ;)

  (global $smile i64 (i64.const 0x3c_42_a5_81_a5_99_42_3c))

  (func $clear_canvas
    (local $i i32)

    (loop $pixel_loop
      (i64.store (local.get $i) (i64.const 0xff_00_00_00_ff_00_00_00))
      (i32.add (local.get $i) (i32.const 8))
      local.set $i

      (i32.lt_u (local.get $i) (global.get $img_buf_size))
      br_if $pixel_loop
    )
  )

  (func $set_pixel
    (param $x i32)
    (param $y i32)
    (param $c i32)
    
    (i32.ge_u (local.get $x) (global.get $cnvs_size))
    if
      return
    end

    (i32.ge_u (local.get $y) (global.get $cnvs_size))
    if
      return
    end

    local.get $y
    global.get $cnvs_size
    i32.mul

    local.get $x
    i32.add

    i32.const 4
    i32.mul

    local.get $c

    i32.store
  )

  (func $render_sprite 
    (param $sprite_data i64)
    (param $color i32)
    (param $x i32)
    (param $y i32)

    (local $i i32)

    (loop $pixel_loop
      local.get $sprite_data 
      i32.const 63 
      local.get $i  ;; [$sprite_data, 64, i]
      i32.sub ;; 64 - $i [$sprite_data, 64 - i]
      i64.extend_i32_u
      i64.shr_u ;; $sprite_data >> (64 - $i)
      i64.const 1
      i64.and ;; ($sprite_data >> (64 - $i)) & 1
      i32.wrap_i64
      if ;; if pixel data is 1
      
        local.get $x
        local.get $i
        i32.const 0x07
        i32.and ;; last 8 bits of $i
        i32.add ;; $x + ($i & 0000 1111) 
        ;; now you have the x value for the pixel

        local.get $y
        local.get $i
        i32.const 3
        i32.shr_u ;; $i / 8
        i32.add ;; $y + ($i / 8)
        ;; now you have the y value for the pixel

        local.get $color

        call $set_pixel
      
      end

      local.get $i  
      i32.const 1   
      i32.add       ;; $i++
      local.tee $i

      i32.const 64
      i32.lt_u
      br_if $pixel_loop
      
    )
  )

    (func (export "main")
      call $clear_canvas
      global.get $smile
      i32.const 0xff_00_ff_ff ;; abgr
      ;; i32.const 100
      global.get $yval
      global.get $yval
      i32.const 1
      i32.add
      global.set $yval
      global.get $yval
      global.get $cnvs_size
      i32.ge_s
      if
        i32.const -7
        global.set $yval
      end
      global.get $yval
      call $render_sprite
    )
  )
