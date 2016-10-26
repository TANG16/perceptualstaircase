# perceptualstaircase

# MATLAB code used to evaluate perceptual thresholds for detecting basic and complex facial expressions.

# This task was designed to measure the minimum amount of perceptual information (i.e. perceptual threshold) necessary to discriminate each expression from a neutral face. It is a two-alternative forced-choice fixed step-size perceptual staircase procedure (Cornsweet, 1962) and was coded for a MacBook Pro computer (12-inch monitor) using MATLAB with Psychophysics Toolbox (Brainard, 1997). 

# The task began with four practice trials in which each of the 100% expressions was paired with a neutral face. Participants identified, ‘Which face shows more expression?’ and were required to respond correctly on each practice trial prior to beginning the experiment. Participants receive audio feedback only during the practice trials.

# The first slide is the title slide for the task, after which the practice trials begin.

# During the task, on each trial, participants see a central fixation and a pair of face stimuli, one directly above and the other directly below the fixation. 

# Participants must decide ‘which face shows more expression’ with a button press. The pair of stimuli include the neutral face and one of the morphed facial expressions. The position of the stimuli is counterbalanced across trials. 

# The first trial includes the neutral and the 64% morph. The staircase procedure proceeded with a 1-down/2-up step size along a log2 function until the participant experi- enced five failures. For each failure, a perceptual threshold was computed as the average of the morphed stimulus from the failed trial and that from the most recent successful trial. For example, if a participant failed at a trial in which the 32% morph was presented the perceptual threshold would be computed as (45% + 32%)/2 = 38.5%. 

# The final perceptual threshold is computed as the average of the five thresholds. We determined that five failures was an appropriate stopping rule for the staircase procedure in this experiment by pilot testing with an independent set of adult and child participants. This criterion appropriately balanced the subject variability, but also interdependence of responses, like anchoring effects and adaptation-level phenomena, perseveration, and anticipation (Corn- sweet, 1962).

# Each expression is tested in a separate block that begins with an image depicting the 100% version of the expression being tested in the block with the instructions, ‘Now you will see this expression.’
