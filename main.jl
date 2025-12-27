using Images, ImageIO, ColorTypes, LinearAlgebra

const palette = RGB{Float32}.([
    RGB(0.0, 0.0, 0.0),
    RGB(1.0, 1.0, 1.0),
    # RGB(1.0, 0.0, 0.0),
    # RGB(0.0, 1.0, 0.0),
    # RGB(0.0, 0.0, 1.0),
    # RGB(1.0, 1.0, 0.0),
    # RGB(1.0, 0.0, 1.0),
    # RGB(0.0, 1.0, 1.0),
])

@inline
function nearest_color(c, palette)
    best = palette[1]
    bestd = Inf32
    for p in palette
        d = (c.r - p.r)^2 + (c.g - p.g)^2 + (c.b - p.b)^2
        if d < bestd
            bestd = d
            best = p
        end
    end
    best
end

function dither(input_path, output_path)
    img = RGB{Float32}.(load(input_path))
    height, width = size(img)

    padded_img = padarray(img, Pad(1, 1))

    for y in 1:height, x in 1:width
        old = padded_img[y, x]
        new = nearest_color(old, palette)
        padded_img[y, x] = new
        err = old - new
        padded_img[y, x+1] += err * 7 / 16
        padded_img[y+1, x-1] += err * 3 / 16
        padded_img[y+1, x] += err * 5 / 16
        padded_img[y+1, x+1] += err * 1 / 16
    end

    save(output_path, clamp01.(padded_img[1:height, 1:width]))
end

function main()
    @assert length(ARGS) == 2 "Expected 2 arguments"
    input_path = ARGS[1]
    output_path = ARGS[2]
    dither(input_path, output_path)
end
@time main()
