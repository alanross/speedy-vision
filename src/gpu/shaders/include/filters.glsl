/*
 * speedy-vision.js
 * GPU-accelerated Computer Vision for JavaScript
 * Copyright 2020-2022 Alexandre Martins <alemartf(at)gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * filters.glsl
 * Image filtering utilities
 */

#ifndef _FILTERS_GLSL
#define _FILTERS_GLSL

/*

Pyramid layers are generated by successive applications
of a 2D Gaussian g(1), i.e., a Gaussian of sigma^2 ~ 1.0.
If I(x,y) is the intensity value of an image at (x,y),
then we have, for each level-of-detail:

lod   intensity
---   ---------
 0    I(x,y)
 1    g(1) * I(x,y)
 2    g(1) * g(1) * I(x,y)
 3    g(1) * g(1) * g(1) * I(x,y)

 and so on, where * denotes convolution.

 The convolution of two Gaussians g(a) and g(b) generates[1]
 a third Gaussian of sigma^2 = a+b, i.e., g(a+b). Therefore,
 the intensity value at (x,y) for lod = t > 0 is g(t) * I(x,y).

 Let L(x,y,t) = g(t) * I(x,y) be the scale-space representation[2]
 of I. The scale-normalized Laplacian of L(x,y,t) is given by[3,4]:

 t \/^2 L = t (Lxx(x,y;t) + Lyy(x,y;t)) = t tr(H(L_t))

 where tr(H(L_t)) is trace of the Hessian of L(x,y;t) (fixed t).

 We adjust for lod = 0 by imagining an image J, twice the size of I,
 such that I(x,y) = g(1) * J(x,y) in normalized [0,1]x[0,1] space.
 The scale-space representation of J is therefore:

 L'(x,y,t) = g(t) * J(x,y) [we set 1+lod = t >= 1].

 The scale-normalized Laplacian of L'(x,y,t) is (1+lod) tr(H(L'_t)).

 [1] Bromiley, Paul. "Products and convolutions of Gaussian probability density functions"
 [2] Lindeberg, Tony. "Scale selection" available at https://people.kth.se/~tony/papers/Lin14-ScSel-CompVisRefGuide.pdf
 [3] https://en.wikipedia.org/wiki/Blob_detection
 [4] https://en.wikipedia.org/wiki/Corner_detection

*/

/**
 * Compute the scale-normalized Laplacian of a pixel
 * at a specific level-of-detail: t * (Lxx + Lyy)
 * @param {sampler2D} pyramid
 * @param {vec2} position
 * @param {float} lod the default is 0
 * @returns {float}
 */
float laplacian(sampler2D pyramid, vec2 position, float lod)
{
    float pot = exp2(lod);
    ivec2 pyrBaseSize = textureSize(pyramid, 0);
    const vec3 ones = vec3(1.0f);
    const mat3 kernel = mat3(
        0,-1, 0,
       -1, 4,-1,
        0,-1, 0
    );

    // read nearby pixels
    //#define LPC(x,y) pyrPixelAtOffset(pyramid, lod, pot, ivec2((x),(y))).g
    #define LPC(x,y) pyrSubpixelAtExOffset(pyramid, position, lod, pot, ivec2((x),(y)), pyrBaseSize).g
    mat3 neighborhood = mat3(
        0.0f, LPC(0,-1), 0.0f,
        LPC(-1,0), LPC(0,0), LPC(1,0),
        0.0f, LPC(0,1), 0.0f
    );

    // compute the Laplacian
    mat3 m = matrixCompMult(neighborhood, kernel);
    return dot(ones, vec3(
        dot(m[0], ones),
        dot(m[1], ones),
        dot(m[2], ones)
    )) * (1.0f + lod);
}

#endif