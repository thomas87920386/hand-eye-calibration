function daVinci = build_da_Vinci_function()
    % Create da Vinci Xi main model
    daVinci = rigidBodyTree('DataFormat', 'column');
    
    % Build da vinci
    sus = create_SUS();
    suj1 = create_SUJ('SUJ1');
    suj2 = create_SUJ('SUJ2');
    suj3 = create_SUJ('SUJ3');
    suj4 = create_SUJ('SUJ4');
    usm1 = create_USM('USM1');
    usm2 = create_USM('USM2');
    usm3 = create_USM('USM3');
    usm4 = create_USM('USM4');
    usm1_end_effect = create_END_EFFECT('USM1_endoscope');
    usm2_end_effect = create_END_EFFECT('USM2_END_EFFECT');
    usm3_end_effect = create_END_EFFECT('USM3_endoscope');
    usm4_end_effect = create_END_EFFECT('USM4_END_EFFECT');
    
    addSubtree(daVinci, 'base', sus);
    addSubtree(daVinci, 'SUS_4', suj1);
    addSubtree(daVinci, 'SUS_4', suj2);
    addSubtree(daVinci, 'SUS_4', suj3);
    addSubtree(daVinci, 'SUS_4', suj4);
    addSubtree(daVinci, 'SUJ1_4', usm1);
    addSubtree(daVinci, 'SUJ2_4', usm2);
    addSubtree(daVinci, 'SUJ3_4', usm3);
    addSubtree(daVinci, 'SUJ4_4', usm4);
    addSubtree(daVinci, 'USM1_5', usm1_end_effect);
    addSubtree(daVinci, 'USM2_5', usm2_end_effect);
    addSubtree(daVinci, 'USM3_5', usm3_end_effect);
    addSubtree(daVinci, 'USM4_5', usm4_end_effect);
end
