uniform sampler2D image;
uniform float threshold;

// compute corner score considering a
// neighboring circumference of 12 pixels
void main()
{
    vec4 pixel = currentPixel(image);
    float ifCorner = step(1.0f, pixel.r);
    float t = clamp(threshold, 0.0f, 1.0f);
    float c = pixel.g;
    float ct = c + t, c_t = c - t;

    // read neighbors
    float p0 = pixelAtOffset(image, ivec2(0, 2)).g;
    float p1 = pixelAtOffset(image, ivec2(1, 2)).g;
    float p2 = pixelAtOffset(image, ivec2(2, 1)).g;
    float p3 = pixelAtOffset(image, ivec2(2, 0)).g;
    float p4 = pixelAtOffset(image, ivec2(2, -1)).g;
    float p5 = pixelAtOffset(image, ivec2(1, -2)).g;
    float p6 = pixelAtOffset(image, ivec2(0, -2)).g;
    float p7 = pixelAtOffset(image, ivec2(-1, -2)).g;
    float p8 = pixelAtOffset(image, ivec2(-2, -1)).g;
    float p9 = pixelAtOffset(image, ivec2(-2, 0)).g;
    float p10 = pixelAtOffset(image, ivec2(-2, 1)).g;
    float p11 = pixelAtOffset(image, ivec2(-1, 2)).g;

    // read bright and dark pixels
    float bs = 0.0f, ds = 0.0f;
    bs += max(c_t - p0, 0.0f);  ds += max(p0 - ct, 0.0f);
    bs += max(c_t - p1, 0.0f);  ds += max(p1 - ct, 0.0f);
    bs += max(c_t - p2, 0.0f);  ds += max(p2 - ct, 0.0f);
    bs += max(c_t - p3, 0.0f);  ds += max(p3 - ct, 0.0f);
    bs += max(c_t - p4, 0.0f);  ds += max(p4 - ct, 0.0f);
    bs += max(c_t - p5, 0.0f);  ds += max(p5 - ct, 0.0f);
    bs += max(c_t - p6, 0.0f);  ds += max(p6 - ct, 0.0f);
    bs += max(c_t - p7, 0.0f);  ds += max(p7 - ct, 0.0f);
    bs += max(c_t - p8, 0.0f);  ds += max(p8 - ct, 0.0f);
    bs += max(c_t - p9, 0.0f);  ds += max(p9 - ct, 0.0f);
    bs += max(c_t - p10, 0.0f); ds += max(p10 - ct, 0.0f);
    bs += max(c_t - p11, 0.0f); ds += max(p11 - ct, 0.0f);

    // corner score
    float score = max(bs, ds) / 12.0f;
    color = vec4(score * ifCorner, pixel.g, score, pixel.a);
}