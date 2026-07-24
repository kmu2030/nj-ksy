param(
  [string]$KsType='',
  [int]$Alignment=8,
  [string[]]$Imports=@('../../nj'),
  [string]$Type='struct'
)

$StructTypeTKsyTemplate = @'
meta:
  id: ${KsType}_t
  application:
    - Sysmac Studio
  license: MIT
  imports:
$(($Imports | ForEach-Object { "    - $_" }) -Join "`n")
  encoding: UTF-8
  endian: le
  bit-endian: le

types:
  # Defined in ``types`` to make it a non-root element.
  ${KsType}:
    seq:
      - id: ${Type}_begin
        type: nj::${Type}_begin('${KsType}', $Alignment)

      # fields

      - id: ${Type}_end
        type: nj::${Type}_end(${Type}_begin)
    instances:
      block_info:
        value: ${Type}_end.${Type}_block_info

  ${KsType}_array_1d:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: ${KsType}
    instances:
      alignment:
        value: v[0].${Type}_end.alignment
      padding:
        value: v[0].${Type}_end.${Type}_padding
      size:
        value: padding + v[0].block_info.len_data * x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, x)

  ${KsType}_array_2d:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y + 0
        type: ${KsType}_array_1d(x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + v[0].block_info.len_data * x * y
      cardinalities:
        value: '[y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, y * x)

  ${KsType}_array_3d:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: z + 0
        type: ${KsType}_array_2d(y, x)
    instances:
      alignment:
        value: v[0].alignment
      padding:
        value: v[0].padding
      size:
        value: padding + v[0].block_info.len_data * x * y * z
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, z * y * x)

  ${KsType}_array_1df:
    params:
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: x + 0
        type: ${KsType}
    instances:
      alignment:
        value: v[0].${Type}_end.alignment
      padding:
        value: v[0].${Type}_end.${Type}_padding
      size:
        value: padding + v[0].block_info.len_data * x
      length:
        value: x
      cardinalities:
        value: '[x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  ${KsType}_array_2df:
    params:
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: y * x 
        type: ${KsType}
    instances:
      alignment:
        value: v[0].${Type}_end.alignment
      padding:
        value: v[0].${Type}_end.${Type}_padding
      size:
        value: padding + v[0].block_info.len_data * x * y
      length:
        value: y * x
      cardinalities:
        value: '[y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)

  ${KsType}_array_3df:
    params:
      - id: z
        type: u2
      - id: y
        type: u2
      - id: x
        type: u2
    seq:
      - id: v
        repeat: expr
        repeat-expr: z * y * x 
        type: ${KsType}
    instances:
      alignment:
        value: v[0].${Type}_end.alignment
      padding:
        value: v[0].${Type}_end.${Type}_padding
      size:
        value: padding + v[0].block_info.len_data * x * y * z
      length:
        value: z * y * x
      cardinalities:
        value: '[z, y, x]'
      block_info:
        type: nj::block_info(v[0].block_info.pos_block, size, v[0].block_info.pos_data, v[0].block_info.ks_type, length)
'@ -replace "`r`n", "`n"

if ( [string]::IsNullOrEmpty($KsType) ) { exit 1 }

$ExecutionContext.InvokeCommand.ExpandString($StructTypeTKsyTemplate)
