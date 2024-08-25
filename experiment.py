one = int(0xffff) # bit-shift 16
r = int(0x310) # bit-shift 8

def iterate(r):
    x = int(0xf03)
    for _ in range(50):
        t = one - x
        #print(hex(t))
        t = x * t
        #print(hex(t))
        t = t >> 16
        #print(hex(t))
        t = r * t
        t = t >> 8
        x = t
        print(hex(x))

print(r)
iterate(r)
r = int(0x380)
print(r)
iterate(r)
