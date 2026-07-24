🌐 **Language:** [English](README.md) | 日本語

# About

KSYとバイナリの例です。
[Kaitai Web IDE](https://ide.kaitai.io/)で使用する場合、 `imports`のパスを修正し、`nj.ksy`と`ksygen.ksy`もアップロードしてください。
KSTは、バイナリを正常にパースできた場合の値を記載しています。
バイナリは、`ExampleDataGenerator.smc2`で生成しています。

### Example Struct

Definition:

|     Name      | Data Type | Offset Type | Byte Offset | Bit Offset | Comment |
|---------------|-----------|-------------|-------------|------------|---------|
| ExampleStruct | STRUCT    | NJ          |             |            |         |
| vel           | LREAL     |             |             |            |         |
| trq           | LREAL     |             |             |            |         |
| acc           | LREAL     |             |             |            |         |
| status_code   | DWORD     |             |             |            |         |

アライメントが8バイトであるのに対し、パッディングを含めたフィールドサイズが28バイトなのでサイズ調整として末尾に4バイトのパッディングが挿入されます。
`status_code`の定義位置を末尾以外にすると、後続フィールドのアライメントを理由とするパッディングが挿入され、その位置が変わります。

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

構造体としてまとめてもパッディングが挿入される要素がなく、配列を個別にした場合と差がありません。
バイナリは、39個のUINT値が並んだ任意のUINT型定義と互換です。

Files:

* uint_array.ksy
* uint_array.bin
* uint_array.kst

### Uint Flat Array

Definition: [Uint Array](#uint-array)に同じ

Files:

* uint_flat_array.ksy
* uint_array.bin
* uint_flat_array.kst

### Uint Repeat Array

Definition: [Uint Array](#uint-array)に同じ

Files:

* uint_repeat_array.bin
* uint_array.bin
* uint_repeat_array.kst
