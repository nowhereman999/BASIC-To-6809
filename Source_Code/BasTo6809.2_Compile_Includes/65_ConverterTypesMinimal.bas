ConvertLastType2NVT:
ScaleSmallNumberOnStack:
ScaleLeft2Right:
ScaleRight2Left:
Z$ = "; Minimal scaling/converting - not doing anything": GoSub ao
Z$ = "; LastType=" + Str$(LastType): GoSub ao
Z$ = "; LeftType=" + Str$(LeftType): GoSub ao
Z$ = "; RightType=" + Str$(RightType): GoSub ao
Z$ = "; NVT=" + Str$(NVT): GoSub ao
Return
