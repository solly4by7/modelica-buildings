within Buildings.Electrical.Transmission.BaseClasses;
partial model PartialLine "Partial cable line dispersion model"
  extends Buildings.Electrical.Interfaces.PartialTwoPort;
  extends Buildings.Electrical.Transmission.BaseClasses.PartialBaseLine;
  Real VoltageLosses = 100*abs(PhaseSystem_p.systemVoltage(terminal_p.v) - PhaseSystem_n.systemVoltage(terminal_n.v))/Buildings.Utilities.Math.Functions.smoothMax(PhaseSystem_p.systemVoltage(terminal_p.v), PhaseSystem_n.systemVoltage(terminal_n.v), 1.0)
    "Percentage of voltage losses across the line";
protected
  parameter Integer n_ = size(terminal_n.i,1);
  parameter Real nominal_i_ = P_nominal / V_nominal;
  parameter Real nominal_v_ = V_nominal;

  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics), Icon(coordinateSystem(
          preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
          Text(
            extent={{-150,-19},{150,-59}},
            lineColor={0,0,0},
          textString="%name")}),
    Documentation(revisions="<html>
<ul>
<li>
June 3, 2014, by Marco Bonvini:<br/>
Added User's guide.
</li>
</ul>
</html>", info="<html>
<p>
This partial model extends the model <a href=\"modelica://Buildings.Electrical.Transmission.Base.PartialBaseLine\">
Buildings.Electrical.Transmission.Base.PartialBaseLine</a> by adding two generalized electric
connectors.
</p>
<h4>Note:</h4>
<p>
See <a href=\"modelica://Buildings.Electrical.Transmission.Base.PartialBaseLine\">
Buildings.Electrical.Transmission.Base.PartialBaseLine</a> for more information.
</p>
</html>"));
end PartialLine;