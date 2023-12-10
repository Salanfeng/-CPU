/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_00000000004032555942_1451755364_init();
    work_m_00000000000635591019_3146453351_init();
    work_m_00000000000191549870_1552539477_init();
    work_m_00000000002989963687_4127636709_init();
    work_m_00000000000660974526_2725559894_init();
    work_m_00000000000689412872_1672990010_init();
    work_m_00000000001343452454_3973486852_init();
    work_m_00000000002398828052_0985782861_init();
    work_m_00000000002114964662_3975733304_init();
    work_m_00000000000919194678_1120148890_init();
    work_m_00000000003741584446_3508565487_init();
    work_m_00000000001348797106_0156190743_init();
    work_m_00000000000056312757_0053799672_init();
    work_m_00000000003225131541_3877310806_init();
    work_m_00000000002148573628_2892433225_init();


    xsi_register_tops("work_m_00000000002148573628_2892433225");


    return xsi_run_simulation(argc, argv);

}
