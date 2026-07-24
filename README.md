🌐 **Language:** English | [日本語](README_ja.md)

# NJ ksy

**NJ ksy** is a KSY-based framework for representing the native binary formats of OMRON Sysmac Studio's primitive types, NJ-layout structs, union types, enumerations, and their arrays using [Kaitai Struct](https://kaitai.io/).

Sysmac Studio employs a memory layout for struct that is similar to that of C or C++.
Padding is inserted based on the order of field definitions and type alignment requirements.
NJ ksy is a set of definitions that statically represents user-defined types from Sysmac Studio while abstracting away memory layout rules.
This enables easy handling of binary data output by PLCs running code compiled in Sysmac Studio, using languages ​​supported by Kaitai Struct.
It also allows for easy adaptation to changes in struct definitions by simply modifying the KSY file and regenerating the parser.

NJ ksy is designed for manipulating binary files output by the PLC to local storage and for representing data via native binary formats for arbitrary data exchange.
Native binary data exchange is not intended to replace vendor-standard protocols.
Rather, it serves as an alternative option when standard protocols struggle to meet requirements regarding frequency, volume, quality, or other factors.

Consider, for instance, a scenario where data is sent locally to an AI model to evaluate the situation, and commands are issued based on that evaluation.
While vendor-standard protocols might be used for data exchanges that alter system behavior—due to constraints regarding quality or the necessity of using dedicated protocols—they may fail to meet requirements for data exchanges related to situational assessment, where frequency and volume are the primary concerns.
In such a case, one viable option is to use a different data exchange method for transmitting data to the AI ​​model, sending the internal binary data directly to minimize the load on the PLC.

Using NJ ksy makes it easy to manipulate binary-format logs and configuration files stored on SD cards.
If you are using NJ layout structures as-is, simply defining them in NJ ksy allows you to generate a read/write parser.
Even if the data includes elements such as BCD-encoded numbers or space-padded fixed-length Shift-JIS strings—due to device constraints—you can still generate a read/write parser by defining and using simple types to interpret them.

The following struct defined in Sysmac Studio is:

|     Name      | Data Type | Offset Type | Byte Offset | Bit Offset | Comment |
|---------------|-----------|-------------|-------------|------------|---------|
| ExampleStruct | STRUCT    | NJ          |             |            |         |
| vel           | LREAL     |             |             |            |         |
| trq           | LREAL     |             |             |            |         |
| acc           | LREAL     |             |             |            |         |
| status_code   | DWORD     |             |             |            |         |

In NJ ksy, it is represented as follows:

```yaml
meta:
  id: example_struct
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  - id: struct_begin
    type: nj::struct_begin('example_struct', 8)

  - id: vel
    type: nj::lreal
  - id: trq
    type: nj::lreal
  - id: acc
    type: nj::lreal
  - id: status_code
    type: nj::dword

  - id: struct_end
    type: nj::struct_end(struct_begin)
```

The following is an example of using a parser generated with Python as the target language.

```python
from example_struct import ExampleStruct

obj = ExampleStruct.from_file("path_to_binary_file")
print(f"vel:{obj.vel.v}, trq:{obj.trq.v}, acc:{obj.acc.v}, status_code:{obj.status_code.v}")
```

## How to Use

NJ ksy defines KSY based on the variable, struct, and union definitions in Sysmac Studio.

### Correspondence between Sysmac Studio's Types and NJ ksy Definitions

In Nj ksy, definitions are distinguished between single primitive types and arrays of primitive types.
For arrays, dedicated types—supporting up to three dimensions—are defined for each primitive type to facilitate alignment calculations and ensure simplicity.
Since Sysmac Studio supports arrays of up to three dimensions, it is possible to represent any type defined in Sysmac Studio based on these primitive types.

The correspondence between Sysmac Studio primitive types and NJ ksy type definitions is as follows:

|     Type      | Alignment |              NJ ksy Definition               |             Value Type             |
|---------------|-----------|----------------------------------------------|------------------------------------|
| USINT         |         1 | nj::usint, nj::usint_array_*                 | u1                                 |
| UINT          |         2 | nj::uint, nj::uint_array_*                   | u2                                 |
| UDINT         |         4 | nj::udint, nj::udint_array_*                 | u4                                 |
| ULINT         |         8 | nj::ulint, nj::ulint_array_*                 | u8                                 |
| SINT          |         1 | nj::sint, nj::sint_array_*                   | s1                                 |
| INT           |         2 | nj::int, nj::int_array_*                     | s2                                 |
| DINT          |         4 | nj::dint, nj::dint_array_*                   | s4                                 |
| LINT          |         8 | nj::lint, nj::lint_array_*                   | s8                                 |
| BOOL          |         2 | nj::bool, nj::bool_array_*                   | b1  (2-byte unit frame)            |
| BYTE          |         1 | nj::byte, nj::byte_array_*                   | u1                                 |
| WORD          |         2 | nj::word, nj::word_array_*                   | u2                                 |
| DWORD         |         4 | nj::dword, nj::dword_array_*                 | u4                                 |
| LWORD         |         8 | nj::lword, nj::lword_array_*                 | u8                                 |
| REAL          |         8 | nj::real, nj::real_array_*                   | f4                                 |
| LREAL         |         8 | nj::lreal, nj::lreal_array_*                 | f8                                 |
| STRING        |         1 | nj::string                                   | str (encoding=UTF-8, terminator=0) |
| TIME          |         8 | nj::time, nj::time_array_*                   | s8  (nanosecond scale)             |
| DATE          |         8 | nj::date, nj::date_array_*                   | u8  (Unix time in nanoseconds)     |
| TIME_OF_DAY   |         8 | nj::time_of_day, nj::time_of_day_array_*     | u8  (Unix time in nanoseconds)     |
| DATE_AND_TIME |         8 | nj::date_and_time, nj::date_and_time_array_* | u8  (Unix time in nanoseconds)     |
| Enum          |         4 | nj::enum_t, nj::enum_t_array_*               | u4                                 |

`*_array_*`, which targets arrays of primitive types, is defined as follows, with the number of elements specified.

| Definition in Sysmac Studio | NJ ksy Definition |
|-|-|
| ARRAY [0..2] OF UINT | nj::uint_array_1d(3) |
| ARRAY [0..2,0..1] OF UINT | nj::uint_array_2d(3,2) |
| ARRAY [0..2,0..1,0..0] OF UINT | nj::uint_array_3d(3,2,1) |

`nj::enum_t` is a generic enumeration type definition.
It can be specified regardless of whether the type is built-in or user-defined.
In Sysmac Studio, enumeration types are interpreted as DWORD types and can thus be evaluated as `u4`.
You can also define a dedicated enumeration type by using the `enum` element.

When defining a union, use the following definition:

| Type  | Alignment |        NJ ksy Definition         |       Value Type        |
|-------|-----------|----------------------------------|-------------------------|
| BOOL  |         2 | nj::u_bool, nj::u_bool_array_*   | b1  (2-byte unit frame) |
| BYTE  |         1 | nj::u_byte, nj::u_byte_array_*   | u1                      |
| WORD  |         2 | nj::u_word, nj::u_word_array_*   | u2                      |
| DWORD |         4 | nj::u_dword, nj::u_dword_array_* | u4                      |
| LWORD |         8 | nj::u_lword, nj::u_lword_array_* | u8                      |

Prefix the type name with `u_`.
If you use a type definition that does not include the `u_` prefix, the parser code can be generated, but it will not function correctly.

### Definition Examples

All definition examples include both the KSY file and the corresponding binary file in the `example` directory.
You can inspect the contents on demand by uploading `nj.ksy` along with the binary file to the [Kaitai Web IDE](https://ide.kaitai.io/).
If you have access to Sysmac Studio, you can also generate and upload an arbitrary binary file, then use the NJ KSY definition to represent its structure and verify the contents.

#### Single Primitive Type

A single primitive type representation simply defines the corresponding type.

```yaml
meta:
  id: uint_single
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: v
    type: nj::uint
```

To reference values ​​in the generated parser, use the `v` property of the field object.

```
uintSingleObj.singleUint.v
```

#### Primitive Type Arrays

Representing a primitive type array simply involves defining the corresponding type.

```yaml
meta:
  id: uint_array
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: array_1d
    type: nj::uint_array_1d(3)

  - id: array_2d
    type: nj::uint_array_2d(3, 3)

  - id: array_3d
    type: nj::uint_array_3d(3, 3, 3)
```

To reference values ​​in the generated parser, use the `v` property of the field object.
The `v` property is an array.
For arrays with two or more dimensions, specify the value element by chaining the `v` property and index specifications.
Since the value element is a Kaitai Struct primitive, the `v` property is not specified for it.

```
uintArrayObj.array1d.v[x]
uintArrayObj.array2d.v[y].v[x]
uintArrayObj.array3d.v[z].v[y].v[x]
```

#### Primitive Type Flat Arrays

There is also a representation that treats the data as a flat array, accessing values ​​via index calculation.

```yaml
meta:
  id: uint_flat_array
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: array_1d
    type: nj::uint_array_1df(3)

  - id: array_2d
    type: nj::uint_array_2df(3, 3)

  - id: array_3d
    type: nj::uint_array_3df(3, 3, 3)
```

Value referencing in the generated parser is the same as for a non-flat one-dimensional array, regardless of the number of array dimensions.

```
uintArrayObj.array_1d.v[x]
uintArrayObj.array_2d.v[y * 3 + x]
uintArrayObj.array_3d.v[z * 3 + y * 3 + x] 
```

#### Arrays as Repetitions of a Single Primitive Type

Defining an array as a repetition of a single primitive type also works.

```yaml
meta:
  id: uint_array_repeat
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le

seq:
  - id: array_1d
    type: nj::uint
    repeat: expr
    repeat-expr: 3

  - id: array_2d
    type: nj::uint
    repeat: expr
    repeat-expr: 3 * 3

  - id: array_3d
    type: nj::uint
    repeat: expr
    repeat-expr: 3 * 3 * 3
```

Since the value reference in the generated parser is an array of a single primitive type, the `v` property is used.

```
uintArrayObj.array_1d.v[x].v
uintArrayObj.array_2d.v[y * 3 + x].v
uintArrayObj.array_3d.v[z * 3 + y * 3 + x].v 
```

#### Struct

A struct is composed of a struct start (`nj::struct_begin`), fields, and a struct completion (`nj::struct_end`) within the `seq` element.
Elements that do not consume the stream can be defined arbitrarily within `seq`.
Elements other than `seq` can also be defined arbitrarily.

```yaml
meta:
  id: example_struct
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  # Define `nj::union_struct` to start the struct definition.
  # Pass the struct identifier and the union alignment to `nj::struct_begin`.
  # The alignment matches the maximum alignment of the fields.
  - id: struct_begin
    type: nj::struct_begin('example_struct', 8) # The alignment for the LREAL type is the maximum.

  # Define fields.
  # Define them in the same order as the structure definition in Sysmac Studio.

  - id: vel
    type: nj::lreal
  - id: trq
    type: nj::lreal
  - id: acc
    type: nj::lreal
  - id: status_code
    type: nj::dword

  # Define `nj::struct_end` to complete the struct definition.
  # Please pass the defined `nj::struct_begin`.
  - id: struct_end
    type: nj::struct_end(struct_begin)
instances:
  # Specifying this allows it to be incorporated into other types.
  block_info:
    value: struct_end.struct_block_info
```

Value references in the generated parser follow the field definitions.

```
exampleStructObj.vel.v
exampleStructObj.trq.v
exampleStructObj.acc.v
exampleStructObj.status_code.v
```

#### Union

A union is composed of a union start (`nj::union_begin`), fields, and a union completion (`nj::union_end`) within the `seq` element.
Elements that do not consume the stream can be defined arbitrarily within `seq`.
Elements other than `seq` can also be defined arbitrarily.

```yaml
meta:
  id: example_union
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  # Define `nj::union_begin` to start the union definition.
  # Pass the union identifier and the union alignment to `nj::union_begin`.
  # The alignment matches the maximum alignment of the fields.
  - id: union_begin
    type: nj::union_begin('example_union', 4) # The alignment for the DWORD type is the maximum.

  # Define fields.
  - id: status_flags
    type: nj::u_bool_array_1d(16)
  - id: segmented_status_codes
    type: nj::u_word_array_1d(2)
  - id: status_code
    type: nj::u_dword

  # Define `nj::union_end` to complete the union definition.
  # Please pass the defined `nj::union_begin` and the `block_info` array for the defined field.
  - id: union_end
    type: nj::union_end(union_begin, [status_flags.block_info, segmented_status_codes.block_info, status_code.block_info]) 
instances:
  # Specifying this allows it to be incorporated into other types.
  block_info:
    value: union_end.union_block_info
```

Value references in the generated parser follow the field definitions.

```
exampleStructObj.status_flats.v[x]
exampleStructObj.segmented_status_codes.v[x]
exampleStructObj.status_code.v
```

## Generating Lightweight KSY

The code generated from `nj.ksy` is massive, and it is rare to require the entirety of it.
If the sole objective is reading and writing binary data, a simple KSY reflecting the memory layout—along with the parser it generates—suffices.
Since the parser generated from a KSY represented by NJ ksy retains memory layout information, code that uses the parser can refer to it to generate any KSY.
While generating arbitrary KSY definitions is possible, doing so requires an understanding of NJ ksy's behavior and the implementation of code to perform the generation.

NJ ksy treats the generation of lightweight KSY as a standard requirement and therefore includes generation capabilities.
The lightweight KSY generated include a immediate-evaluation type, which parse fields during parser generation,
and a lazy-evaluation type, which parse fields upon access.
Lightweight KSY can be generated for both struct and unions.
However, only the lazy-evaluation type is valid for unions.

As shown below, by referencing the lightweight KSY generation module in KSY and defining its elements,
the parser generates a JSON string for the lightweight KSY.

```yaml
meta:
  id: example_struct
  license: MIT
  imports:
    - nj
    - ksygen # References the lightweight KSY generation module.
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  - id: struct_begin
    type: nj::struct_begin('example_struct', 8)

  - id: vel
    type: nj::lreal
  - id: trq
    type: nj::lreal
  - id: acc
    type: nj::lreal
  - id: status_code
    type: nj::dword

  - id: struct_end
    type: nj::struct_end(struct_begin)
instances:
  block_info:
    value: struct_end.struct_block_info
  
  # Defines the values required by the lightweight KSY generator.
   # Passes the defined `nj::struct_end`, field identifiers, and an array of the fields' `block_info` properties.
  struct_info:
    type: >-
      nj::struct_info(
        struct_end,
        ['vel', 'trq', 'acc', 'status_code'],
        [vel.block_info, trq.block_info, acc.block_info, status_code.block_info]
      )
  # Define a lightweight KSY generator.
  to_ksy:
    # Passes structure information, the type identifier suffix for an lazy-evaluation KSY, and a single KSY flag.
    type: ksygen::to_ksy(struct_info.as_container_info, '_view', true)
  lazy_eval_ksy:
    value: to_ksy.lazy_eval_ksy.value # JSON string for the lazy-evaluation KSY.
  immediate_eval_ksy:
    value: to_ksy.immediate_eval_ksy.value # JSON string for the immediate-evaluation KSY.
```

To generate a KSY from the KSY that defines the lightweight KSY type, you need parser code.
Compile it using **ksc** along with the KSY referenced in `imports` to generate the KSY.
The following example compiles the KSY using the ksc built into the Docker image used by this repository.

```
./kst.ps1 ksc example/example_struct.ksy --target python --outdir example/compiled
```

Once the parser code is generated, use it to generate a parser and retrieve the value of the property holding the lightweight KSY.
Below is a Python script that outputs the YAML for the lazy-evaluation KSY and the immediately-evaluation KSY from the generated parser to the terminal.

```python
import json
from io import StringIO
from ruamel.yaml import YAML
from example_struct import ExampleStruct

# Create an object from an arbitrary byte sequence.
obj = ExampleStruct.from_bytes(b'\x00' * 100)

yaml = YAML()
yaml.default_flow_style = False
yaml.default_allow_unicode = True
yaml.indent(sequence=4, offset=2)

ksy = StringIO()
for prop in ['lazy_eval_ksy', 'immediate_eval_ksy']:
  yaml.dump(json.loads(getattr(obj, prop)), ksy)
  print('---')
  print(ksy.getvalue())
  ksy.truncate(0)
  ksy.seek(0)
```

The output lazy-evaluation KSY is as follows.
It can be compiled standalone and does not require `nj.ksy`.
Alignment adjustment elements are defined to ensure it functions correctly when embedded within other structures.

```yaml
meta:
  id: example_struct
  -alloc-size: 32
  -size: 28
  -alignment: 8
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  # This unnamed element adjusts the alignment.
  - type: u1
    repeat: expr
    repeat-expr: (8 - (_io.pos % 8)) % 8
  - id: block
    type: single_block(32,true)
instances:
  view:
    type: example_struct_view(block.io_block)
  vel:
    value: view.vel
  trq:
    value: view.trq
  acc:
    value: view.acc
  status_code:
    value: view.status_code
types:
  example_struct_view:
    params:
      - id: block
        type: io
    instances:
      vel:
        io: block
        pos: 0
        type: f8
      trq:
        io: block
        pos: 8
        type: f8
      acc:
        io: block
        pos: 16
        type: f8
      status_code:
        io: block
        pos: 24
        type: u4
  single_block:
    params:
      - id: len_block
        type: u2
      - id: as_stream
        type: b1
    seq:
      - id: stream_block
        type: block(len_block)
        size: len_block + 0
        if: as_stream
      - id: block
        type: block(len_block)
        if: not as_stream
    instances:
      io_block:
        value: 'as_stream ? stream_block._io : block._io'
  block:
    params:
      - id: len_mem
        type: u2
    seq:
      - id: mem
        size: len_mem
  bool:
    seq:
      - id: value
        type: b1
  bools:
    params:
      - id: num_value
        type: u2
    seq:
      - id: value
        type: b1
        repeat: expr
        repeat-expr: num_value
```

The output immediate-evaluation KSY is as follows.
Like the lazy-evaluation KSY, it defines elements for alignment adjustment.
It may also define elements for adjusting the allocation size of struct.

```yaml
meta:
  id: example_struct
  -alloc-size: 32
  -size: 28
  -alignment: 8
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  # This unnamed element adjusts the alignment.
  - type: u1
    repeat: expr
    repeat-expr: (8 - (_io.pos % 8)) % 8
  - id: vel
    type: f8
  - id: trq
    type: f8
  - id: acc
    type: f8
  - id: status_code
    type: u4
  # This unnamed element adjusts the allocation size of the struct.
  - type: u1
    repeat: expr
    repeat-expr: 4
```

## Testing NJ ksy

This repository includes the KSY test tool, allowing you to run tests for NJ ksy.
Running NJ ksy tests requires Docker Desktop or a container tool compatible with the `docker` command.
The following test tools are used.

https://github.com/kmu2030/kaitai-struct-test-tool

The NJ ksy tests are organized as follows.

* `tests_primitive`: Tests for primitive types
* `tests_struct`: Tests for structs
* `tests_union`: Tests for unions
* `tests_mixed`: Tests involving mixed types

To run the tests, execute the following command directly within each directory.

```
./kst.ps1 test
```

Test results are output to the terminal.

Running the following command executes the tests and outputs the results as an xUnit-format report to `test_out` in the test directory.

```
./kst.ps1 ci
```

## Testing custom KSY

As a test for a custom KSY that uses NJ ksy, you can perform visual evaluations using Kaitai Web IDE or Visualizer,
but by defining a KST and ensuring it is ready for testing alongside the binary, you can perform a comprehensive evaluation.

Just like with the NJ ksy tests, you can set up a dedicated test directory,
but the evaluation results are the same even if you use an instant test directory such as `example`.
Running the following command from the repository's root directory will execute the instant `example` test and output the results to the terminal.

```
./kst.ps1 itest example
```

Running the following command in the repository's root directory will run an instant test for `example` and output the report to `example/test_out`.

```
./kst.ps1 ici example
```

To perform an instant test similar to the `example`,
create a suitable directory under the repository directory,
place KSY, KST, and the binary files there,
and then run the instant test from the repository's root directory by specifying the path to that directory.
For example, the following performs an instant test on `myksy/struct1`.

```
./kst.ps1 itest myksy/struct1
```

For information on KST, please check the following or examine the `.kst` file in the `example` directory.

https://doc.kaitai.io/kst.html

## License

* KSY (`nj.ksy`, `ksygen.ksy`): GPL-3.0-or-later
