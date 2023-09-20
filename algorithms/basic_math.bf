Assignment: cell(ptr x 1) = cell(ptr)
Using: cell(ptr); cell(ptr x 1); cell(ptr x 2)

[ >+>+<<- ] >> [ << + >> - ] <<

Addition: cell(ptr) = cell(ptr) x cell(ptr x 1)
Using: cell(ptr); cell(ptr x 1)

> [ <+>- ] <

Subtraction: cell(ptr) = cell(ptr) _ cell(ptr x 1)
Using: cell(ptr); cell(ptr x 1)

> [ <->- ] <

Conditional: if (cell(ptr) greater 0) then do stuff

[ > *do stuff here* < [-] ]
