#Setup by loading into $4
lw $4 2($0) #$4 = 5
noop        # Empty pipeline, we are not testing this.
noop
noop
noop

#Start test 1
add $1 $4 $0   #$1 = 5
noop           #Not testing this part, nop
noop
lw $1 1($0)    #Load 10 into $1
add $2 $1 $0   #Add 0 to $1. This is the hazard we are testing.
noop	       #Not tested here
noop
noop
sw $2 10($0)  #Store the result. 10 if it works, otherwise 5

# Test 2
add $1 $4 $0  # $1 = 5
noop
noop
lw $1 1($0)   # load 10 into $1
noop          # This is the task of the forwarding unit
sw $1 11($0)  # Store $1. This is the hazard.



8c040002
00000000
00000000
00000000
00000000
00800820
00000000
00000000
8c010001
00201020
00000000
00000000
00000000
ac02000a
00800820
00000000
00000000
8c010001
00000000
ac01000b



X"8c040002", --lw $4 2($0)
X"00000000", --noop
X"00000000", --noop
X"00000000", --noop
X"00000000", --noop
X"00800820", --add $1 $4 $0
X"00000000", --noop
X"00000000", --noop
X"8c010001", --lw $1 1($0)
X"00201020", --add $2 $1 $0
X"00000000", --noop
X"00000000", --noop
X"00000000", --noop
X"ac02000a", --sw $2 10($0)
X"00800820", --add $1 $4 $0
X"00000000", --noop
X"00000000", --noop
X"8c010001", --lw $1 1($0)
X"00000000", --noop
X"ac01000b", --sw $1 11($0)

X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"", --lw $1, 1($0)
X"8C010001", --lw $1, 1($0)
X"8C010001", --lw $1, 1($0)
X"8C010001", --lw $1, 1($0)
X"8C010001", --lw $1, 1($0)
X"8C010001", --lw $1, 1($0)
X"8C010001", --lw $1, 1($0)


