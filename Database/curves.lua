local SCM = select(2, ...)
SCM.Curves = {}

local Curves = SCM.Curves

local function CreateConstantCurve(value)
    local curve = C_CurveUtil.CreateCurve();
    curve:AddPoint(0, value);
    curve:AddPoint(999999, value);
    return curve;
end

local curveBelowTwoMinutes = C_CurveUtil.CreateCurve();
curveBelowTwoMinutes:SetType(Enum.LuaCurveType.Step);
curveBelowTwoMinutes:AddPoint(0, 2);
curveBelowTwoMinutes:AddPoint(119.99, 2);
curveBelowTwoMinutes:AddPoint(120, 1);
curveBelowTwoMinutes:AddPoint(999999, 1);

Curves.UnitCount = {
    [1] = CreateConstantCurve(1),
    [2] = CreateConstantCurve(2),
    [3] = curveBelowTwoMinutes,
}
