# -*- coding: utf-8 -*-
"""
Created on Tue Nov  7 11:19:01 2023

@author: netpc01
"""

import random
import numpy as np

class Snake:
    '''
    classdocs
    '''
    # we modify the function by adding the orientation indice
    # this allow us to locate the head part of the snake 
    
    def __init__(self, kParams):
        self.x = int(random.random()*kParams['map_w'])
        self.y = int(random.random()*kParams['map_h'])
        self.z = random.randint(1, 3) 
        #self.z=int(random.random()*kParams['orientation'])

    def state_transition(self, command):
        # Generate a random number between 0 and 3 to determine the direction of movement
        random_generated_nbr = random.randint(0, 3)
        
        # Case when the random number indicates moving to the "right"
        if random_generated_nbr == 0:  # right
            if self.z == 1:  # Facing DOWN, move one step down along the y-axis
                self.y += 1
            elif self.z == 2:  # Facing RIGHT, move one step right along the x-axis
                self.x += 1
            elif self.z == 3:  # Facing UP, move one step up along the y-axis
                self.y -= 1
        
        # Case when the random number indicates moving to the "left"
        elif random_generated_nbr == 1:  # left
            if self.z == 1:  # Facing UP, move one step up along the y-axis
                self.y -= 1
            elif self.z == 2:  # Facing LEFT, move one step left along the x-axis
                self.x -= 1
            elif self.z == 3:  # Facing DOWN, move one step down along the y-axis
                self.y += 1
        
        # Case when the random number indicates moving "up"
        elif random_generated_nbr == 2:  # up
            if self.z == 1:  # Facing LEFT, move one step left along the x-axis
                self.x -= 1
            elif self.z == 2:  # Facing UP, move one step up along the y-axis
                self.y -= 1
            elif self.z == 3:  # Facing RIGHT, move one step right along the x-axis
                self.x += 1
        
        # Case when the random number indicates moving "down"
        elif random_generated_nbr == 3:  # down
            if self.z == 1:  # Facing RIGHT, move one step right along the x-axis
                self.x += 1
            elif self.z == 2:  # Facing DOWN, move one step down along the y-axis
                self.y += 1
            elif self.z == 3:  # Facing LEFT, move one step left along the x-axis
                self.x -= 1
        
        # If none of the cases are matched (should not happen), return 0
        else:
            return 0
    
        # Ensure the x and y coordinates wrap around to remain within the range [0, 200)
        self.x %= 200
        self.y %= 200



   
    def get_measurement_probability(self, measure):
        
        # Create a 3x3 matrix of coordinate tuples surrounding (self.x, self.y)
        matrix = [[(self.x + i + 1, self.y + j + 1) for j in [-1, 0, 1]] for i in [-1, 0, 1]]
        
        # Iterate through each coordinate in the matrix
        for i1 in range(3):
            for j1 in range(3):
                # Update self.x and self.y to the current matrix coordinates
                self.x, self.y = matrix[i1][j1]
        
                # Check if the value at the previous cell in 'measure' is 255
                if measure[0][self.x - 1, self.y - 1, 0] == 255:
                    # Check if the value to the left matches the current position
                    if measure[0][self.x - 2, self.y - 1, 0] == measure[0][self.x - 1, self.y - 1, 0]:
                        self.x += 1  # MOVE ONE STEP AHEAD
                        
                    # Check if the value above matches the current position
                    elif measure[0][self.x - 1, self.y - 2, 0] == measure[0][self.x - 1, self.y - 1, 0]:
                        self.y += 1  # MOVE ONE STEP DOWN
        
                    return 1
        
                # Check if the value at the current position is still 255
                elif measure[0][self.x, self.y, 0] == 255:
                    # Check if the value to the right matches the current position
                    if measure[0][self.x + 1, self.y, 0] == measure[0][self.x, self.y, 0]:
                        self.x -= 2  # MOVE TWO STEPS LEFT
                    # Check if the value below matches the current position
                    elif measure[0][self.x, self.y + 1, 0] == measure[0][self.x, self.y, 0]:
                        self.y -= 2  # MOVE TWO STEPS UP
        
                    return 1
        
                else:
                    # If no conditions are met, return failure
                    return 0
        
                # Keep coordinates within the range [0, 200)
                self.x %= 200
                self.y %= 200

