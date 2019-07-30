const war2 = Process.getModuleByName("Warcraft II BNE_dx.exe");

const MAP_HACK_ADDR     = ptr("0x0042D4EA");
const MAP_HACK_ON       = [0xB8, 0x00, 0x00, 0x00, 0x00]; // B8 10101010    MOV EAX,10101010
const MAP_HACK_OFF      = [0xB8, 0x10, 0x10, 0x10, 0x10]; // B8 00000000    MOV EAX,0

const MINIMAP_HACK_ADDR = ptr("0x0042D4FC");
const MINIMAP_HACK_ON   = [0x83, 0xC8, 0x00];             // 83C8 FF        OR EAX,FFFFFFFF
const MINIMAP_HACK_OFF  = [0x83, 0xC8, 0xFF];             // 83C8 00        OR EAX,0

const toggleMapHack = function () {
  // read the bytes from MAP_HACK_ADDR and convert to usable array
  var currentState = new Uint8Array(MAP_HACK_ADDR.readByteArray(3));

  // check if 2nd byte has been zero'ed out (first byte is always 0xB8 so pointless checking that) to determine hack state
  if (currentState[1] !== 0) {
    Memory.patchCode(MAP_HACK_ADDR, 5, function(p) {
      p.writeByteArray(MAP_HACK_ON);
    });

    Memory.patchCode(MINIMAP_HACK_ADDR, 3, function(p) {
      p.writeByteArray(MINIMAP_HACK_ON);
    });

    return "Enabled maphack";

  } else {
    Memory.patchCode(MAP_HACK_ADDR, 5, function(p) {
      p.writeByteArray(MAP_HACK_OFF);
    });

    Memory.patchCode(MINIMAP_HACK_ADDR, 3, function(p) {
      p.writeByteArray(MINIMAP_HACK_OFF);
    });

    return "Disabled maphack";
  }
}
