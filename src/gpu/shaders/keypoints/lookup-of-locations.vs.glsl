/*
 * speedy-vision.js
 * GPU-accelerated Computer Vision for JavaScript
 * Copyright 2020-2021 Alexandre Martins <alemartf(at)gmail.com>
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
 * lookup-of-locations.vs.glsl
 * Create a lookup table with keypoint locations from a corners texture
 * (vertex shader)
 */

#if !defined(STAGE) || STAGE < 1
#error Invalid STAGE
#else

uniform mediump int blockSize;

out vec2 v_topLeft, v_top, v_topRight,
         v_left, v_center, v_right,
         v_bottomLeft, v_bottom, v_bottomRight;

void main()
{
    float b = float(blockSize);
    setupVertexShader();

    #define V(x,y) (texCoord + (vec2((x),(y)) * b) / texSize)
    v_topLeft = V(-1,-1); v_top = V(0,-1); v_topRight = V(1,-1);
    v_left = V(-1,0); v_center = V(0,0); v_right = V(1,0);
    v_bottomLeft = V(-1,1); v_bottom = V(0,1); v_bottomRight = V(1,1);
}

#endif