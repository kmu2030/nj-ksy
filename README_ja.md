🌐 **Language:** [English](README.md) | 日本語

# NJ ksy

**NJ ksy**は、OMRON社のSysmac Studioの基本型、NJレイアウトの構造体、共用型、列挙型とそれら配列のネイティブバイナリを、[Kaitai Struct](https://kaitai.io/)で表現するためのKSYによるフレームワークです。
Sysmac Studioでは、構造体についてCやC++に類似したメモリ配置を施します。フィールドの定義順序と型のアライメントに応じたパッディングが挿入されます。
NJ ksyは、Sysmac Studioで定義する任意型についてメモリ配置規則を隠蔽して静的に表現する定義セットです。
これにより、Kaitai Structがサポートする言語において、Sysmac Studioでコンパイルしたコードが動作するPLCが出力するバイナリを簡単に扱うことができます。
また、構造体の定義変更についてもKSYの修正とパーサ再生成で容易に追従することができます。

NJ ksyは、PLCがローカルストレージに出力するバイナリファイルの操作、ネイティブバイナリによる任意のデータ交換手段でのデータ表現を目的としています。
ネイティブバイナリによるデータ交換は、ベンダー標準のプロトコルを代替するものではありません。
目的に対してそのプロトコルが、頻度、容量、品質等の要件を満たし難い場合の選択肢の一つです。

例えば、ローカルでAIモデルにデータを送り状況を評価しつつ場合によって、指令を送る場合を考えてみてください。
振る舞いを変更するデータ交換は、品質あるいは専用プロトコル経由という制約からベンダー標準のプロトコルを使用するも、状況評価に関連したデータ交換は、頻度と容量がフォーカスされそのプロトコルが要件を満たせないことはあり得ます。
この場合、AIモデル向けのデータ送信は他のデータ交換手段を採用し、PLCの負荷を抑えるために内部バイナリをそのまま送ることが選択肢の一つとなります。

NJ ksyを使用すれば、SDカードに蓄積したバイナリフォーマットのログや設定ファイルを操作することも簡単です。
NJレイアウトの構造体をそのまま使用しているのであれば、それをNJ ksyで表現するだけで読み書き可能なパーサを生成できます。
その一部に使用機器の制約によりBCD表現の数値やスペースでパッドされた固定長のシフトJS文字列が含まれていても、それらを解釈する簡素な型を定義して使用することで、読み書き可能なパーサを生成することができます。

Sysmac Studioで定義した以下の構造体は、

|     Name      | Data Type | Offset Type | Byte Offset | Bit Offset | Comment |
|---------------|-----------|-------------|-------------|------------|---------|
| ExampleStruct | STRUCT    | NJ          |             |            |         |
| vel           | LREAL     |             |             |            |         |
| trq           | LREAL     |             |             |            |         |
| acc           | LREAL     |             |             |            |         |
| status_code   | DWORD     |             |             |            |         |

NJ ksyで以下のように表現します。

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

以下は、Pythonを対象言語として生成したパーサの使用例です。

```python
from example_struct import ExampleStruct

obj = ExampleStruct.from_file("path_to_binary_file")
print(f"vel:{obj.vel.v}, trq:{obj.trq.v}, acc:{obj.acc.v}, status_code:{obj.status_code.v}")
```

## 使い方

NJ ksyは、Sysmac Studioでの変数定義、構造体、共用体定義に沿ってKSYを定義します。

### 型と定義の対応

Nj ksyでの定義は、単一の基本型と基本型の配列とで分かれます。
配列については、アライメント計算と簡素さを目的に各基本型について三次元まで専用型を定義しています。
Sysmac Studioの配列は三次元までとなっているので、基本型についてSysmac Studioで定義された任意の型を表現できます。

Sysmac Studioの基本型とNJ ksyの定義の対応は以下です。

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
| REAL          |         4 | nj::real, nj::real_array_*                   | f4                                 |
| LREAL         |         8 | nj::lreal, nj::lreal_array_*                 | f8                                 |
| STRING        |         1 | nj::string                                   | str (encoding=UTF-8, terminator=0) |
| TIME          |         8 | nj::time, nj::time_array_*                   | s8  (nanosecond scale)             |
| DATE          |         8 | nj::date, nj::date_array_*                   | u8  (Unix time in nanoseconds)     |
| TIME_OF_DAY   |         8 | nj::time_of_day, nj::time_of_day_array_*     | u8  (Unix time in nanoseconds)     |
| DATE_AND_TIME |         8 | nj::date_and_time, nj::date_and_time_array_* | u8  (Unix time in nanoseconds)     |
| Enum          |         4 | nj::enum_t, nj::enum_t_array_*               | u4                                 |

基本型の配列を対象とする`*_array_*`は、以下のように定義し、要素数を指定します。

| Definition in Sysmac Studio | NJ ksy Definition |
|-|-|
| ARRAY [0..2] OF UINT | nj::uint_array_1d(3) |
| ARRAY [0..2,0..1] OF UINT | nj::uint_array_2d(3,2) |
| ARRAY [0..2,0..1,0..0] OF UINT | nj::uint_array_3d(3,2,1) |

`nj::enum_t`は、汎用の列挙型定義です。
組み込み、ユーザー定義であるかに関係なく指定できます。
Sysmac Studioにおいて列挙型はDWORD型と解釈されるため`u4`として評価し、KSの`enum`を付して専用の列挙型を定義することもできます。

共用体を定義する場合、以下の定義を使用します。

| Type  | Alignment |        NJ ksy Definition         |       Value Type        |
|-------|-----------|----------------------------------|-------------------------|
| BOOL  |         2 | nj::u_bool, nj::u_bool_array_*   | b1  (2-byte unit frame) |
| BYTE  |         1 | nj::u_byte, nj::u_byte_array_*   | u1                      |
| WORD  |         2 | nj::u_word, nj::u_word_array_*   | u2                      |
| DWORD |         4 | nj::u_dword, nj::u_dword_array_* | u4                      |
| LWORD |         8 | nj::u_lword, nj::u_lword_array_* | u8                      |

`u_`を型の名称の前に付加します。
共用体の定義に`u_`を付加していない定義を使用すると、パーサコードの生成はできますが機能しません。

### 定義例

全ての定義例は、`example`にKSYとバイナリがあります。
[Kaitai Web IDE](https://ide.kaitai.io/)に`nj.ksy`と合わせてアップロードすることでオンデマンドに内容を確認できます。
Sysmac Studioを使用できるようであれば、任意のバイナリを生成してアップロードし、NJ ksyで構造を表現して内容を確認することもできます。

#### 単一基本型

単一基本型の表現は、対応する型を定義するだけです。

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

生成したパーサでの値参照には、フィールドオブジェクトの`v`プロパティを使用します。

```
uintSingleObj.singleUint.v
```

#### 基本型配列

基本型配列の表現は、対応する型を定義するだけです。

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

生成したパーサでの値参照には、フィールドオブジェクトの`v`プロパティを使用します。
`v`プロパティは配列です。
二次元以上の配列は、`v`プロパティとインデックス指定を繰り返して値要素を指定します。
値要素はKaitai Structのプリミティブであるため、`v`プロパティは指定しません。

```
uintArrayObj.array1d.v[x]
uintArrayObj.array2d.v[y].v[x]
uintArrayObj.array3d.v[z].v[y].v[x]
```

#### 基本型フラット配列

フラットな配列としてインデックス計算で値を参照する表現もあります。

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

生成したパーサでの値参照は、配列の次元数に依らず非フラットな一次元配列と同じです。

```
uintArrayObj.array_1d.v[x]
uintArrayObj.array_2d.v[y * 3 + x]
uintArrayObj.array_3d.v[z * 3 * 3 + y * 3 + x] 
```

#### 単一基本型の繰り返しによる配列

配列を単一基本型の繰り返しとして定義しても機能します。

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

生成したパーサでの値参照は、単一基本型の配列なので`v`プロパティを使用します。

```
uintArrayObj.array_1d.v[x].v
uintArrayObj.array_2d.v[y * 3 + x].v
uintArrayObj.array_3d.v[z * 3 * 3 + y * 3 + x].v 
```

#### 構造体

構造体は、`seq`要素に構造体開始(`nj::struct_begin`)、フィールド、構造体完了(`nj::struct_end`)を定義して構成します。
ストリームを消費しない要素であれば、`seq`に任意に定義できます。
`seq`以外の要素については、任意に定義できます。

```yaml
meta:
  id: example_struct
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  # `nj::struct_begin`を定義し、構造体の定義を開始します。
  # 構造体の識別子と構造体のアライメントを渡します。
  # 構造体のアライメントは、アライメントが最大であるフィールドのアライメントに一致します。
  - id: struct_begin
    type: nj::struct_begin('example_struct', 8) # LREAL型のアライメントが最大であり、8バイトです。

  # フィールドを定義します。
  # Sysmac Studioでの構造体定義と同じ順序で定義します。

  - id: vel
    type: nj::lreal
  - id: trq
    type: nj::lreal
  - id: acc
    type: nj::lreal
  - id: status_code
    type: nj::dword

  # `nj::struct_end`を定義し、構造体の定義を完了します。
  # 構造体の開始として定義した`nj::struct_begin`を渡します。
  - id: struct_end
    type: nj::struct_end(struct_begin)
instances:
  # このプロパティを定義することで`NJ ksy`互換として他の構造体に組み込めるようになります。
  block_info:
    value: struct_end.struct_block_info
```

生成したパーサでの値参照は、各フィールドの定義に従います。

```
exampleStructObj.vel.v
exampleStructObj.trq.v
exampleStructObj.acc.v
exampleStructObj.status_code.v
```

#### 共用体

共用体は、`seq`要素に共用体開始(`nj::union_begin`)、フィールド、共用体完了(`nj::union_end`)で構成します。
ストリームを消費しない要素であれば、`seq`に任意に定義できます。
`seq`以外の要素については、任意に定義できます。

```yaml
meta:
  id: example_union
  imports:
    - nj
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  # `nj::union_begin`を定義し、共用体の定義を開始します。
  # 共用体の識別子と共用体のアライメントを渡します。
  # 共用体のアライメントは、アライメントが最大であるフィールドのアライメントに一致します。
  - id: union_begin
    type: nj::union_begin('example_union', 4) # DWORD型のアライメントが最大であり、4バイトです。

  # フィールドを定義します。
  - id: status_flags
    type: nj::u_bool_array_1d(16)
  - id: segmented_status_codes
    type: nj::u_word_array_1d(2)
  - id: status_code
    type: nj::u_dword

  # `nj::union_end`を定義し、共用体の定義を完了します。
  # 共用体の開始として定義した`nj::union_begin`、フィールドの`block_info`プロパティの配列を渡します。
  - id: union_end
    type: nj::union_end(union_begin, [status_flags.block_info, segmented_status_codes.block_info, status_code.block_info]) 
instances:
  # このプロパティを定義することで`NJ ksy`互換として他の構造体に組み込めるようになります。
  block_info:
    value: union_end.union_block_info
```

生成したパーサでの値参照は、フィールドの定義に従います。

```
exampleStructObj.status_flats.v[x]
exampleStructObj.segmented_status_codes.v[x]
exampleStructObj.status_code.v
```

## 軽量KSYの生成

`nj.ksy`から生成されるコードは巨大で、その全てを必要とすることは稀です。
バイナリの読み書きだけが目的であれば、メモリ配置を反映した簡素なKSYとそれが生成するパーサで十分です。
NJ ksyで表現したKSYから生成されるパーサは、メモリ配置情報を保持しているため、パーサを使用するコードがそれを参照して任意のKSYを生成することは可能です。
任意のKSYを生成できますが、NJ ksyの振る舞いの理解と生成のためのコードが必要になります。

NJ ksyは、軽量なKSYの生成を一般的な要求と考えているため、生成手段を備えています。
生成する軽量KSYは、パーサ生成時にフィールドをパースする即時評価型KSYとフィールドアクセス時にパースする遅延評価型KSYがあります。
軽量KSYの生成は、構造体、共用体のいずれも可能ですが、共用体では遅延評価型KSYのみが有効です。

軽量KSYの生成は以下のように、KSYで軽量KSY生成モジュールを参照し、その要素を定義することで軽量KSYのJSON文字列をパーサにおいて生成します。

```yaml
meta:
  id: example_struct
  license: MIT
  imports:
    - nj
    - ksygen # 軽量KSY生成モジュールを参照します。
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
  
  # 軽量KSY生成型が必要とする値を定義します。
  # 定義した`nj::struct_end`とフィールド識別子、フィールドの`block_info`プロパティの配列を渡します。
  struct_info:
    type: >-
      nj::struct_info(
        struct_end,
        ['vel', 'trq', 'acc', 'status_code'],
        [vel.block_info, trq.block_info, acc.block_info, status_code.block_info]
      )
  # 軽量KSY生成型を定義します。
  to_ksy:
    # 構造体情報、遅延評価型KSYの型識別子サフィックス、単一KSYフラグを渡します。
    type: ksygen::to_ksy(struct_info.as_container_info, '_view', true) 
  lazy_eval_ksy:
    value: to_ksy.lazy_eval_ksy.value # 遅延評価型KSYのJSONです。
  immediate_eval_ksy:
    value: to_ksy.immediate_eval_ksy.value # 即時評価型KSYのJSONです。
```

軽量KSY型を定義したKSYからKSYを生成するには、パーサコードが必要です。
`imports`で参照するKSYと合わせて**ksc**でコンパイルして生成します。
以下は、このリポジトリが使用しているDockerが内蔵するkscを使用してKSYをコンパイルします。

```
./kst.ps1 ksc example/example_struct.ksy --target python --outdir example/compiled
```

パーサコードを生成したら、それを使用してパーサを生成し、軽量KSYを保持するプロパティの値を取得します。
以下は、生成したパーサから遅延評価型KSY、即時評価型KSYのYAMLをターミナルに出力するPythonスクリプトです。

```python
import json
from io import StringIO
from ruamel.yaml import YAML
from example_struct import ExampleStruct

# 適当なバイト列でオブジェクトを生成します。
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

以下は、出力される遅延評価型KSYです。
`nj.ksy`を必要とせず、単体でコンパイル可能です。
他の構造体に組み込んでも機能するよう、アライメント調整要素を定義しています。

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
  # この無名要素は、アライメントを調整します。
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

出力される即時評価型KSYは、以下です。
遅延評価型KSY同様、アライメント調整要素を定義しています。
また、構造体のアロケーションサイズ調整要素を定義している場合があります。

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
  # この無名要素は、アライメントを調整します。
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
  # この無名要素は、構造体のアロケーションサイズを調整します。
  - type: u1
    repeat: expr
    repeat-expr: 4
```

## NJ ksyのテスト

このリポジトリはKSYテストツールを内蔵しているため、NJ ksyのテストを実施できます。
NJ ksyのテストには、Docker Desktopまたは、`docker`コマンド互換のコンテナツールが必要です。
テストツールは以下を使用しています。

https://github.com/kmu2030/kaitai-struct-test-tool

NJ ksyのテストは、以下に分かれています。

* `tests_primitive`: 基本型のテスト
* `tests_struct`: 構造体のテスト
* `tests_union`: 共用体のテスト
* `tests_mixed`: 複合的なテスト

テストの実施は、それぞれのディレクトリ直下で以下を実行します。

```
./kst.ps1 test
```

テスト結果は、ターミナルに出力します。

以下を実行するとテストを実施し、テスト結果をテストディレクトリ直下の`test_out`にxUnit形式のレポートとして出力します。

```
./kst.ps1 ci
```

## ユーザー定義KSYのテスト

NJ ksyを使用するユーザー定義KSYのテストとして、Kaitai Web IDEやVisualizerで目視評価することもできますが、
KSTを定義し、バイナリと共にテストできるようにしておくことで網羅的な評価が行えるようになります。

NJ ksyのテスト同様に専用のテストディレクトリを構成することもできますが、
`example`のような簡易テストディレクトリでも評価内容は同じです。
以下をリポジトリのルートディレクトリで実行すると、`example`の簡易テストを実施してテスト結果をターミナルに出力します。

```
./kst.ps1 itest example
```

以下をリポジトリのルートディレクトリで実行すると、`example`の簡易テストを実施してレポートを`example/test_out`に出力します。

```
./kst.ps1 ici example
```

`example`同様の簡易テストを行う場合、リポジトリのディレクトリ下に適当なディレクトリを作成し、KSY、KST、バイナリを配置、
リポジトリのルートディレクトリにおいてそのディレクトリへのパスを指定して簡易テストを実施できます。
例えば、以下は`myksy/struct1`を対象として簡易テストを実施します。

```
./kst.ps1 itest myksy/struct1
```

KSTについては、以下を確認するか`example`の`.kst`ファイルを確認してください。

https://doc.kaitai.io/kst.html

## ライセンス

* KSY (`nj.ksy`, `ksygen.ksy`): GPL-3.0-or-later
