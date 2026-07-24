🌐 **Language:** English | [日本語](README_ja.md)

# About

Here are the KSY and binary examples.
If using the [Kaitai Web IDE](https://ide.kaitai.io/), please adjust the `imports` paths and upload `nj.ksy` and `ksygen.ksy` as well.
The KST file lists the expected values ​​obtained when the binary is successfully parsed.
The binary was generated using `ExampleDataGenerator.smc2`.

### Example Struct

Definition:

|     Name      | Data Type | Offset Type | Byte Offset | Bit Offset | Comment |
|---------------|-----------|-------------|-------------|------------|---------|
| ExampleStruct | STRUCT    | NJ          |             |            |         |
| vel           | LREAL     |             |             |            |         |
| trq           | LREAL     |             |             |            |         |
| acc           | LREAL     |             |             |            |         |
| status_code   | DWORD     |             |             |            |         |

Since the alignment requirement is 8 bytes but the field size—including padding—is 28 bytes,
4 bytes of padding are inserted at the end to adjust the size.
If the definition of `status_code` is moved from the end to another position,
padding is inserted due to the alignment requirements of subsequent fields, causing the position to change.

Files:

* example_struct.ksy
* example_struct.bin
* example_struct.kst

### Example Union

Definition:

|          Name          |      Data Type       | Comment |
|------------------------|----------------------|---------|
| ExampleUnion           | UNION                |         |
| status_flags           | ARRAY[0..15] OF BOOL |         |
| segmented_status_codes | ARRAY[0..1] OF WORD  |         |
| status_code            | DWORD                |         |

Files:

* example_union.ksy
* example_union.bin
* example_union.ksy

### Uint Single

Definition: Primitive

Files:

* uint_single.ksy
* uint_single.bin
* uint_single.kst

### Uint Array

Definition:

|        Name        |           Data Type           | Offset Type | Byte Offset | Bit Offset | Comment |
|--------------------|-------------------------------|-------------|-------------|------------|---------|
| UintArrayContainer | STRUCT                        | NJ          |             |            |         |
| array_1d           | ARRAY[0..2] OF UINT           |             |             |            |         |
| array_2d           | ARRAY[0..2,0..2] OF UINT      |             |             |            |         |
| array_3d           | ARRAY[0..2,0..2,0..2] OF UINT |             |             |            |         |

Even when grouped into a structure, no padding is inserted, so there is no difference compared to treating the array elements individually.
The binary data is compatible with any definition of a sequence of 39 `UINT` values.

Files:

* uint_array.ksy
* uint_array.bin
* uint_array.kst

### Uint Flat Array

Definition: Same as [Uint Array](#uint-array)

Files:

* uint_flat_array.ksy
* uint_array.bin
* uint_flat_array.kst

### Uint Repeat Array

Definition: Same as [Uint Array](#uint-array)

Files:

* uint_repeat_array.bin
* uint_array.bin
* uint_repeat_array.kst
