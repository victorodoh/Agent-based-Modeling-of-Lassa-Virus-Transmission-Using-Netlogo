AGENT-BASED MODELLING OF LASSA VIRUS TRANSMISSION USING NETLOGO

This model simulates Lassa Virus Transmission, an endemic predominantly in the western region of Africa. It is able to estimate the size of imminent attacks at any time based on some input parameters. It can be used to analyze the degree of impact of community hygiene and social distancing on the virus transmission rate over time, and can serve as a research aid tool for epidemiologists or health organisations.

#### HOW TO RUN THE MODEL: ####

1. Via Netlogo Modelling Commons:
- [Load Link](http://modelingcommons.org/browse/one_model/7141#browse_nlw)
- Click the "Run in Netlogo Web" tab to open the window, then click anywhere within this window to run model.

2. Via Netlog Desktop:
- Download and install Netlogo for Mac/windows/Linux : https://ccl.northwestern.edu/netlogo/6.1.1/
- Download the "Lassa Fever Transmission.nlogo" file of this repo
- Open the .nlogo downloaded file in the Netlogo app to launch interface for simulation.


#### HOW IT WORKS: ####

THE INTERFACE

![](Interface%20Pics/Model%20Interface.png)

Interface includes sets of parameters in the form of sliders which users can use to adjust the inputs based on the requirements of their experiment.

- Initialize Simulation; It is configured as a “once-only” button to setup or initialize the simulation. Clicking this button activates the “setup” command procedure, a block of codes written in the code tab.

- Run/Pause Simulation; This is configured as a “forever” button. Clicking this button activates the “go” command procedure in the code tab which then runs / pauses the simulation.


#### HOW TO USE THE MODEL: ####

- Human_Population: This slider can be used by a user to select a variable number of human agents to be populated into the world (Graphics window). Since at least two persons are required for a viral transmission to occur, the minimum number for the slider was set to “2”. After selecting the desired number of human agents, clicking the Initialize Simulation button will reset the simulation and reflect the set number of human agents all placed randomly across the world.

- MultimammateRatPopulation: to select a variable number of infectious rat agents which the user needs to be populated into the world. Clicking the Initialize Simulation button sets up the simulation with the desired number of rats and places them randomly across the world.

- InitialNumberOf_Cases: For selecting a pre-existing number of cases (infectious human agents) at the beginning of the simulation. Clicking the Initialize Simulation button displays the selected Initial number of cases scattered randomly among all agents within the world.

- %Severe_Cases: This indicates the percentage of the initial number of infected human agents that were severely affected by the virus. Based on the user’s selection, the system computes and populates the exact number of infected humans with severe symptoms in the world.

- Incubation_Period: It represents the length of time in days that it will take for a newly infected human to begin to exhibit some symptoms and become infectious. Users can select a variable number of days depending on what their simulation/ experiment needs.

- Sick_Days: Length of time in days for an infectious human to either recover or die from fighting the virus. This begins to count immediately after the incubation period elapses. Sliding left or right selects a variable number of days which the system uses to perform calculations and actions based on some conditions.

- InfectiousDaysAfter_Recovery: Length of time in days that the virus lasts in a human agent that survived the viral infection and had become immune. During these days, the human agent is still infectious and hence, still poses a risk (though minimal) of infecting other nearby humans in contact. A variable number of days can be selected as required for simulation.

- CFRMildCase: For selecting or adjusting the Case Fatality Rate (CFR) in percentage for infectious human agents with mild symptoms. The system takes whatever value that was selected as an input argument and calculates the probability of the agent dieing after the Sick Days has elapsed.

- CFRSevereCase: For selecting the Case Fatality Rate in percentage for infectious human agents with severe symptoms. Just like the former, the user can adjust or modify the parameter value. The system then computes the Case Fatality Rate to determine if the human agent dies or not.

- %InfectiousnessRatto_Humans: This slider can be used to set the probability in percentage, of a rat-to-human transmission for every instance of time when an uninfected human agent gets in contact with rat agent.

- %InfectiousnessHumanto_Human: A user can use this slider to select the probability in percentage, of a human-to-human transmission of the virus for every instance of time that an uninfected human agent gets in contact with an already infectious human agent.

- HumanBehaviourFactor: A factor which represents the level of hygiene or social distancing being practiced by humans in the world. The least value that can be selected is set at 0.01 and the highest value is set at 0.99. This system uses this value to adjust the speed of both agent sets in slightly different ways. The higher the value, the higher the degree of hygiene practice (and vice versa) which will mitigate the activities of the disease carrying rats in the world. This behavior is represented in the model by slowing down the speed (activities) of the rat agents, as well as improving social distancing for the human agents. The speed of both agent sets gets slower as the value gets higher.

#### THINGS TO NOTICE: ####

The color changes helps to monitor the transition from one health status to the other, of the human agents.

- White Human: Healthy, not infected.
- Yellow Human: future case
- Orange Human: Mild case.
- Red Human: Severe case.
- Cyan Human: Immune carriers
- Lime Human: Fully recovered and immune
- Gray Human: Dead human
- Rats in red

POPULATED WORLD

![](Interface%20Pics/Populated%20World.png)

#### THINGS TO TRY: ####
- You can adjust the HumanBehaviourFactor slider to see how the level of comminity hygiene / social distance being practiced affects the Lassa virus transmission.

- You can also adjust the human / rat population to analyze the effect of population density on the Lassa virus transmission.
