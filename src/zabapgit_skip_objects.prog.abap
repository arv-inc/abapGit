*&---------------------------------------------------------------------*
*& Include zabapgit_skip_objects
*&---------------------------------------------------------------------*

CLASS lcl_skip_objects IMPLEMENTATION.
  METHOD skip_sadl_generated_objects.
    DATA: ls_ddls_class_result LIKE LINE OF rt_results,
          lo_sadl_class        TYPE REF TO lif_object,
          ls_item              TYPE  lif_defs=>ty_item,
          ls_result            LIKE LINE OF rt_results,
          lt_lines_to_delete   TYPE lif_defs=>ty_results_tt.

    rt_results = it_results.
    LOOP AT it_results INTO ls_result WHERE obj_type = 'DDLS'.
      LOOP AT it_results INTO ls_ddls_class_result
       WHERE obj_type = 'CLAS' AND obj_name CS ls_result-obj_name.

        IF has_sadl_superclass( ls_ddls_class_result ).
          APPEND ls_ddls_class_result TO lt_lines_to_delete.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    SORT lt_lines_to_delete BY filename.
    DELETE ADJACENT DUPLICATES FROM lt_lines_to_delete.
    LOOP AT lt_lines_to_delete INTO ls_ddls_class_result.
      DELETE TABLE rt_results FROM ls_ddls_class_result.
      io_log->add(
        iv_msg = |{ ls_ddls_class_result-filename } skipped: generated by SADL|
        iv_type = 'W' ).
    ENDLOOP.
  ENDMETHOD.

  METHOD has_sadl_superclass.
    DATA: lo_oo_functions TYPE REF TO lif_oo_object_fnc,
          lv_class_name   TYPE seoclsname,
          lv_superclass   TYPE seoclsname.

    lo_oo_functions = lcl_oo_factory=>make( is_class-obj_type ).
    lv_class_name = is_class-obj_name.
    lv_superclass = lo_oo_functions->read_superclass( lv_class_name ).
    IF lv_superclass = 'CL_SADL_GTK_EXPOSURE_MPC'.
      rv_return = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
