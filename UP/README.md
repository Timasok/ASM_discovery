This project is a set of tasks that use common functions
Here what functions contain in different files

    DRAW.ASM  - funcs of drawing lines, frames, symbols
    READ.ASM  - funcs that help to handle parameters from cmd line or users input
    CALC.ASM  - funcs that translate numbers from one number system to another, make operations with them
    WRITE.ASM - funcs that write messages at the screen
    BASE.ASM  - some basic macro's and funcs
    STRING.ASM- contains basic string functions
    DEF_STR.ASM- define of special symbols like '\n', '\0' neccesary to work with stings and write!
    3_BUF.ASM - has funcs to print registers, clear screen and display messages this functions operate mostly with draw buffer
    INT_HAND - module that intercepts interuptions
        INT_8   - periodic redrawing of the screen(including multi buffer juggling)
        INT_9   - key_board control check

    CLEAR.BAT - number of comands to remove not ASM file after compilation

    TASK_i.ASM, TASK_i.BAT DEF_i.ASM - files related exactly to the i-th task