![OpenLadder](https://github.com/user-attachments/assets/34f0edcc-4ab4-4ea0-a4e6-440912ef28a6)
OpenLadder is a graphical tool use to generate binary code for microcontrollers. 
The goal of this project is to give to the community a tool to learn and use Ladder langage with cheap electronics cards.
It can be used for educational purpose or personal projects, the license is GPL V3.
Be careful, OpenLadder 0.1 is a very new version, use it at your own risk and don't use it where security is necessary in industrial processes for example.

### OpenLadder principle:
The Ladder network build with the designer is converted to pascal langage. 
With the simulator, a binary executable is generated and launched as a secondary task. So the result of the executed task is the same as it could be on a real PLC.
For the target, a binary executable is générated with the FPC cross compiler and can be downloaded to the microcontroller.
At this moment, only the Raspberry Pico is supported as a target for OpenLadder. Help is welcomed to port it on other target.

### Tools:
A set of tools can be used for the first version of OpenLadder:
- contacts,coil,set coils,reset coils,Positive trigger,negative trigger,comments
- compare function for numerical variable
- store function
- time function ( TOn,TOff,Flash )

### Examples:
a set of minimal examples is available in the examples folder.


