within Buildings.Fluid.Sensors;
model LatentEnthalpyFlowRate
  "Ideal enthalphy flow rate sensor that outputs the latent enthalpy flow rate only"
  extends Buildings.Fluid.Sensors.BaseClasses.PartialDynamicFlowSensor(tau=0);
  extends Modelica.Icons.RotationalSensor;
  // redeclare Medium with a more restricting base class. This improves the error
  // message if a user selects a medium that does not contain the function
  // enthalpyOfLiquid(.)
  replaceable package Medium =
      Modelica.Media.Interfaces.PartialCondensingGases
      annotation (choicesAllMatching = true);
  parameter Integer i_w = 1 "Index for water substance";
  Modelica.Blocks.Interfaces.RealOutput H_flow(unit="W")
    "Latent enthalpy flow rate, positive if from port_a to port_b"
    annotation (Placement(transformation(
        origin={0,110},
        extent={{-10,-10},{10,10}},
        rotation=90)));
  parameter Modelica.SIunits.SpecificEnthalpy h_out_start=
    Medium.specificEnthalpy_pTX(Medium.p_default, Medium.T_default, Medium.X_default)
    -Medium.enthalpyOfNonCondensingGas(
      Medium.temperature(Medium.setState_phX(
        Medium.p_default, Medium.T_default, Medium.X_default)))
    "<html>Initial or guess value of measured specific <b>latent</b> enthalpy</html>"
    annotation (Dialog(group="Initialization"));
  Modelica.SIunits.SpecificEnthalpy hMed_out(start=h_out_start)
    "Medium latent enthalpy to which the sensor is exposed";
  Modelica.SIunits.SpecificEnthalpy h_out(start=h_out_start)
    "Medium latent enthalpy that is used to compute the enthalpy flow rate";
protected
  Medium.MassFraction XiActual[Medium.nXi]
    "Medium mass fraction to which sensor is exposed to";
  Medium.SpecificEnthalpy hActual
    "Medium enthalpy to which sensor is exposed to";
  Medium.ThermodynamicState sta "Medium state to which sensor is exposed to";
  parameter Integer i_w_internal(fixed=false) "Index for water substance";
initial algorithm
  // Compute index of species vector that carries the water vapor concentration
  i_w_internal :=-1;
    for i in 1:Medium.nXi loop
      if Modelica.Utilities.Strings.isEqual(string1=Medium.substanceNames[i],
                                            string2="Water",
                                            caseSensitive=false) then
        i_w_internal :=i;
      end if;
    end for;
  assert(i_w_internal > 0, "Substance 'water' is not present in medium '"
                  + Medium.mediumName + "'.\n"
                  + "Change medium model to one that has 'water' as a substance.");
  assert(i_w == i_w_internal, "Parameter 'i_w' must be set to '" + String(i_w) + "'.\n");
initial equation
 // Compute initial state
 if dynamic then
    if initType == Modelica.Blocks.Types.Init.SteadyState then
      der(h_out) = 0;
    elseif initType == Modelica.Blocks.Types.Init.InitialState or
           initType == Modelica.Blocks.Types.Init.InitialOutput then
      h_out = h_out_start;
    end if;
 end if;
equation
  if allowFlowReversal then
     XiActual = Modelica.Fluid.Utilities.regStep(port_a.m_flow,
                 port_b.Xi_outflow,
                 port_a.Xi_outflow, m_flow_small);
     hActual = Modelica.Fluid.Utilities.regStep(port_a.m_flow,
                 port_b.h_outflow,
                 port_a.h_outflow, m_flow_small);
  else
     XiActual = port_b.Xi_outflow;
     hActual = port_b.h_outflow;
  end if;
  // Specific enthalpy measured by sensor
  sta = Medium.setState_phX(port_a.p, hActual, XiActual);
  // Compute H_flow as difference between total enthalpy and enthalpy on non-condensing gas.
  // This is needed to compute the liquid vs. gas fraction of water, using the equations
  // provided by the medium model
  hMed_out = (hActual -
     (1-XiActual[i_w]) * Medium.enthalpyOfNonCondensingGas(Medium.temperature(sta)));
  if dynamic then
    der(h_out) = (hMed_out-h_out)*k/tau;
  else
    h_out = hMed_out;
  end if;
  // Sensor output signal
  H_flow = port_a.m_flow * h_out;
annotation (defaultComponentName="senLatEnt",
  Diagram(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},{100,
            100}}), graphics),
  Icon(graphics={
        Line(points={{-100,0},{-70,0}}, color={0,128,255}),
        Line(points={{70,0},{100,0}}, color={0,128,255}),
        Line(points={{0,100},{0,70}}, color={0,0,127}),
        Text(
          extent={{180,151},{20,99}},
          lineColor={0,0,0},
          textString="HL_flow"),
        Ellipse(
          extent={{-70,70},{70,-70}},
          lineColor={0,0,0},
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-5,5},{5,-5}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(points={{0,0},{9.02,28.6}}, color={0,0,0}),
        Polygon(
          points={{-0.48,31.6},{18,26},{18,57.2},{-0.48,31.6}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(points={{0,70},{0,40}}, color={0,0,0}),
        Line(points={{-22.9,32.8},{-40.2,57.3}}, color={0,0,0}),
        Line(points={{-37.6,13.7},{-65.8,23.9}}, color={0,0,0}),
        Line(points={{22.9,32.8},{40.2,57.3}}, color={0,0,0}),
        Line(points={{37.6,13.7},{65.8,23.9}}, color={0,0,0})}),
  Documentation(info="<html>
<p>
This component monitors the <i>latent</i> enthalphy flow rate of the medium in the flow
between fluid ports. In particular, if the total enthalpy flow rate is
<p align=\"center\" style=\"font-style:italic;\">
  H&#775;<sub>tot</sub> = H&#775;<sub>sen</sub> + H&#775;<sub>lat</sub>,
</p>
where 
<i>H&#775;<sub>sen</sub> = m&#775; (1-X<sub>w</sub>) c<sub>p,air</sub></i>, 
then this sensor outputs <i>H&#775; = H&#775;<sub>lat</sub></i>. 
</p>
<p>
If the parameter <code>tau</code> is non-zero, then the measured
specific latent enthalpy <i>h<sub>out</sub></i> that is used to 
compute the latent enthalpy flow rate 
<i>H&#775;<sub>lat</sub> = m&#775; h<sub>out</sub></i> 
is computed using a first order differential equation. 
See <a href=\"modelica://Buildings.Fluid.Sensors.UsersGuide\">
Buildings.Fluid.Sensors.UsersGuide</a> for an explanation.
</p>
<p>
For a sensor that measures 
<i>H&#775;<sub>tot</sub></i>, use
<a href=\"modelica://Buildings.Fluid.Sensors.EnthalpyFlowRate\">
Buildings.Fluid.Sensors.EnthalpyFlowRate</a>.<br>
For a sensor that measures 
<i>H&#775;<sub>sen</sub></i>, use
<a href=\"modelica://Buildings.Fluid.Sensors.SensibleEnthalpyFlowRate\">
Buildings.Fluid.Sensors.SensibleEnthalpyFlowRate</a>.
<p>
The sensor is ideal, i.e., it does not influence the fluid.
The sensor can only be used with medium models that implement the function
<code>enthalpyOfNonCondensingGas(state)</code>.
</p>
</html>
", revisions="<html>
<ul>
<li>
November 3 2011, by Michael Wetter:<br>
Moved <code>der(h_out) := 0;</code> from the initial algorithm section to 
the initial equation section
as this assignment does not conform to the Modelica specification.
</li>
<li>
August 10, 2011 by Michael Wetter:<br>
Added parameter <code>i_w</code> and an assert statement to
make sure it is set correctly. Without this change, Dymola
cannot differentiate the model when reducing the index of the DAE.
</li>
<li>
June 3, 2011 by Michael Wetter:<br>
Revised implementation to add dynamics in such a way that 
the time constant increases as the mass flow rate tends to zero.
This can improve the numerics.
</li>
<li>
February 22, by Michael Wetter:<br>
Improved code that searches for index of 'water' in medium model.
</li>
<li>
September 9, 2009 by Michael Wetter:<br>
First implementation.
Implementation is based on enthalpy sensor of <code>Modelica.Fluid</code>.
</li>
</ul>
</html>"));
end LatentEnthalpyFlowRate;
