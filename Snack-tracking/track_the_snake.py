#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import matplotlib.pyplot as plt
import imageio.v2 as imageio


from particlesFilter import ParticlesFilter
from snake_2 import Snake


if __name__ == "__main__":

    part_filter = ParticlesFilter(1000, Snake, map_w=200, map_h=200)
    plt.ion()

    for i in range(1000):
        
        print('itération ', i)

        part_filter.compute_state_transition()

        img = imageio.imread("snake_color/snake_" + str(i).zfill(4) + ".png")

        part_filter.compute_weights(img)
        part_filter.resample()

        for particle in part_filter.particles_set:
            img[particle.x, particle.y, 2] = 255
            img[particle.x, particle.y, 1] = 0
            
            

        plt.imshow(img, interpolation="None")
        plt.show()
        plt.imsave("track/snake_" + str(i).zfill(4) + ".png", img)
        input()

