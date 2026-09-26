from dataclasses import dataclass
@dataclass(frozen=True)
class Packet: src:int; dst:int; data:int
def arbitrate(packets, ports=4):
 out=[None]*ports
 for p in packets:
  if out[p.dst] is None: out[p.dst]=p
 return out
def test():
 p=[Packet(0,2,10),Packet(1,2,20),Packet(2,3,30)]; o=arbitrate(p); assert o[2].src==0 and o[3].data==30; print('reference model PASS')
if __name__=='__main__':test()
