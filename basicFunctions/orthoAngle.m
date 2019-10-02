function [orthAnglePos, orthAngleNeg] = orthoAngle(angle)
% Calculates the positive and negative orthogonal angles of a given angle

orthAnglePos = angle +90;
orthAngleNeg = angle - 90;

if orthAnglePos >= 360
    orthAnglePos = orthAnglePos-360;
end

if orthAngleNeg< 0
orthAngleNeg = orthAngleNeg + 360;
end

end