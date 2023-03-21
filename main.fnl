(fn split-little-endian [number]
  [(band 255 number) (band 255 (rshift number 8))])

(fn get-random-byte []
  (math.random 0 255))

(fn get-noise-rgb-array [width height]
  (local rgb-array [])
  (for [_ 1 (* width height 3)]
        (table.insert rgb-array (get-random-byte)))
  rgb-array)

(fn write-image-file [filename header rgb-array]
  (local fp (io.open filename "wb"))
  (fp:write header)
  (each [_ byte (ipairs rgb-array)]
    (fp:write (string.char byte)))
  (fp:close))

(fn write-ppm-file [filename rgb-array width height]
  ; https://en.wikipedia.org/wiki/Netpbm#Description
  (local header (string.format "P6 %d %d 255\n" width height))
  (write-image-file filename header rgb-array))

(fn write-tga-file [filename rgb-array width height]
  (local [width-fst width-snd] (split-little-endian width))
  (local [height-fst height-snd] (split-little-endian height))

  ; https://en.wikipedia.org/wiki/Truevision_TGA#Technical_details
  (local header [])

  ; Image ID length (1 byte)
  (tset header 1 0) ; No image ID.

  ; Color map type (1 byte)
  (tset header 2 0) ; No color map.

  ; Image type (1 byte)
  (tset header 3 2) ; Uncompressed true-color image.

  ; Color map specification (5 bytes)
  (tset header 4 0) ; No color map.
  (tset header 5 0) ; No color map.
  (tset header 6 0) ; No color map.
  (tset header 7 0) ; No color map.
  (tset header 8 0) ; No color map.

  ; Image specification (10 bytes)
  (tset header  9 0) ; X origin fst byte.
  (tset header 10 0) ; X origin snd byte.
  (tset header 11 0) ; Y origin fst byte.
  (tset header 12 0) ; Y origin snd byte.
  (tset header 13 width-fst) ; Width fst byte.
  (tset header 14 width-snd) ; Width snd byte.
  (tset header 15 height-fst) ; Height fst byte.
  (tset header 16 height-snd) ; Height snd byte.
  (tset header 17 24) ; Bits per pixel.
  (tset header 18 32) ; Pixel ordering is top-to-bottom.

  (write-image-file filename (string.char (unpack header)) rgb-array))

(fn main []
  (local width 500)
  (local height 400)
  (local rgb-array (get-noise-rgb-array width height))
  (write-ppm-file "_randomimg.ppm" rgb-array width height)
  (write-tga-file "_randomimg.tga" rgb-array width height))

(main)
