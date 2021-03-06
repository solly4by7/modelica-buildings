within Districts.Electrical.DC.Sources;
model WindTurbine
  "Wind turbine with power output based on table as a function of wind speed"
  import Districts;
  extends Districts.Electrical.Interfaces.PartialWindTurbine(redeclare package
      PhaseSystem = Districts.Electrical.PhaseSystems.TwoConductor, redeclare
      Districts.Electrical.DC.Interfaces.Terminal_p
                                                 terminal);
protected
  Loads.Conductor                       con(mode=Districts.Electrical.Types.Assumption.VariableZ_P_input)
    "Conductor, used to interface power with electrical circuit"
    annotation (Placement(transformation(extent={{60,-10},{80,10}})));
equation
  connect(con.terminal, terminal) annotation (Line(
      points={{60,0},{-100,0}},
      color={0,0,255},
      smooth=Smooth.None));
  connect(gain.y, con.Pow) annotation (Line(
      points={{13,20},{94,20},{94,0},{80,0}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}), graphics),
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}),
        graphics={
        Text(
          extent={{-150,70},{-50,20}},
          lineColor={0,0,255},
          textString="+"),
        Text(
          extent={{-150,-12},{-50,-62}},
          lineColor={0,0,255},
          textString="-")}),
    Documentation(info="<html>
<p>
Model of a wind turbine whose power is computed as a function of wind-speed as defined in a table.
</p>
<p>
Input to the model is the local wind speed.
The model requires the specification of a table that maps wind speed in meters per second to generated
power <i>P<sub>t</sub></i> in Watts.
The model has a parameter called <code>scale</code> with a default value of one
that can be used to scale the power generated by the wind turbine.
The generated electrical power is 
<p align=\"center\" style=\"font-style:italic;\">
P = P<sub>t</sub> scale = u i,
</p>
<p>
where <i>u</i> is the voltage and <i>i</i> is the current.
For example, the following specification (with default <code>scale=1</code>) of a wind turbine
</p>
<pre>
  WindTurbine_Table tur(
    table=[3.5, 0;
           5.5,   100;    
           12, 900;
           14, 1000;
           25, 1000]) \"Wind turbine\";
</pre>
<p>
yields the performance shown below. In this example, the cut-in wind speed is <i>3.5</i> meters per second,
and the cut-out wind speed is <i>25</i> meters per second,
as entered by the first and last entry of the wind speed column.
Below and above these wind speeds, the generated power is zero.
</p>
<p align=\"center\">
<img src=\"modelica://Districts/Resources/Images/Electrical/DC/Sources/WindTurbine_Table.png\"/>
</p>
</html>", revisions="<html>
<ul>
<li>
January 10, 2013, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end WindTurbine;
