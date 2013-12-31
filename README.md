Artificial_Ecosystem
====================

An artificial ecosystem to explain the concept of Adaptivity.

Adaptive Systems- Demonstration of flocking behavior:

In this project, I built an artificial ecosystem with Prey, predators, Food and Obstacles to demonstrate the definition of adaptivity with respect to flocking behavior in specific.

The number of agents, i.e. the number of prey and predators in the ecosystem can be modified live time. The main idea behind this system is that the prey agents exhibit a flocking behavior as they move towards food. The predators that are introduced in the system creates disturbances in the flocking behavior as they move towards the flock.

The system is built in processing. The GUI includes a (800 X 600) scaled window with four coloured buttons on the Object control panel. The White button is used to add a prey to the ecosystem, the red button is to add a predator, Green button is to add an obstacle, and yellow button is to add food. The green button turns on the obstacle drawing mode that enables the user to draw obstacles inside the ecosystem in the preffered size. The yellow button turns on the target mode that allows the user to add a single element of food in the ecosystem. Since this is an artificial ecosystem defining prey, predator, energy and food the life inside ecosystem is defined by the colour of the agents. The colour of the agents change as and when the energy level drops. They turn black when the energy level hits zero or when a prey is hunted by a predator, and kill it. The energy level of the prey increases as they keep moving in a flock and hit on food, and the energy level of a predator increases when it kills a prey and consumes it. Also the speed of the flock movement can be changed as the mouse hovers towards the left/right side of the window. This is the general overall view of the system designed.

Algorithm : 
The rules defined in Reynolds’ system are implemented as follows. The centre of mass of the flock is nothing but the average of all position vectors of the neighboring Boids. However, the average position does not give the centre of mass of the complete flock. The perceived centre of mass of the Boids is calculated, that is the all the surrounding Boids are considered. In this algorithm, the perceived centre is calculated based on the placement of food and also the vicinity of the Boid flock to the food. Thus, wherever the user places food, the Boid flocks towards the same. Until food is placed, Flocking behavior is not exhibited by the Boids. This is essentially the nature of an artificial ecosystem. 

Secondly, the Boids try to keep a small distance away from each other and other objects in the ecosystem. The method evasion_distance( ) is responsible for this rule. The purpose of this method is to make sure they don’t collide with each other. This is defined for all states of the system. According to the method definition, the Boids that are very close to each other are not immediately repelled. This is because if two boids are nearby each other, this method is applied on both of them. Initially they are slightly steered away from each other, and after that they are pushed further apart if they are still not far enough to maintain the safe distance defined.

Thirdly, the copy( ) function is used to copy the velocity to a temporary vector and a portion of this is added to the current velocity just so that the overall velocity of the Boids are maintained. The third rule mentions that the Boids try to match velocity with their nearby Boids.

