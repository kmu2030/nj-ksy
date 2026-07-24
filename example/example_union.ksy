meta:
  id: example_union
  imports:
    - ../nj
    - ../ksygen
  encoding: UTF-8
  endian: le
  bit-endian: le
seq:
  - id: union_begin
    type: nj::union_begin('example_union', 4)

  - id: status_flags
    type: nj::u_bool_array_1d(16)
  - id: segmented_status_codes
    type: nj::u_word_array_1d(2)
  - id: status_code
    type: nj::u_dword

  - id: union_end
    type: nj::union_end(union_begin, [status_flags.block_info, segmented_status_codes.block_info, status_code.block_info]) 
instances:
  block_info:
    value: union_end.union_block_info
  
  fields:
    type: fields
  union_info:
    type: >-
      nj::union_info(
        union_end,
        ['status_flags', 'segmented_status_codes', 'status_code'],
        [status_flags.block_info, segmented_status_codes.block_info, status_code.block_info]
      )
  to_ksy:
    type: ksygen::to_ksy(union_info.as_container_info, '_view', true)
  lazy_eval_ksy:
    value: to_ksy.lazy_eval_ksy.value

types:
  fields:
    instances:
      status_flags:
        value: _parent.status_flags.v
      segmented_status_codes:
        value: _parent.segmented_status_codes.v
      status_code:
        value: _parent.status_code.v
