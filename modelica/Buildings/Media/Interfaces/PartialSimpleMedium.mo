within Buildings.Media.Interfaces;
partial package PartialSimpleMedium
  "Medium model with linear dependency of u, h from temperature. All other quantities, especially density, are constant."

  extends Modelica.Media.Interfaces.PartialPureSubstance(final ThermoStates=
        Choices.IndependentVariables.pT, final singleState=true);

  import SI = Modelica.SIunits;
  constant SpecificHeatCapacity cp_const
    "Constant specific heat capacity at constant pressure";
  constant SpecificHeatCapacity cv_const
    "Constant specific heat capacity at constant volume";
  constant Density d_const "Constant density";
  constant DynamicViscosity eta_const "Constant dynamic viscosity";
  constant ThermalConductivity lambda_const "Constant thermal conductivity";
  constant VelocityOfSound a_const "Constant velocity of sound";
  constant Temperature T_min "Minimum temperature valid for medium model";
  constant Temperature T_max "Maximum temperature valid for medium model";
  constant Temperature T0=reference_T "Zero enthalpy temperature";
  constant MolarMass MM_const "Molar mass";

  constant FluidConstants[nS] fluidConstants "fluid constants";

  redeclare record extends ThermodynamicState "Thermodynamic state"
    AbsolutePressure p "Absolute pressure of medium";
    Temperature T "Temperature of medium";
  end ThermodynamicState;

  redeclare replaceable model extends BaseProperties(
    T(stateSelect=if preferredMediumStates then StateSelect.prefer else 
                       StateSelect.default),
    p(stateSelect=if preferredMediumStates then StateSelect.prefer else 
                       StateSelect.default)) "Base properties"

  // Compressibility of water (used to break algebraic loops)
  constant Real kT = 0 "Compressibility factor at constant temperature";
  constant Modelica.SIunits.AbsolutePressure p0 = 3E5
      "Reference pressure for compressibility";

  equation
        assert(T >= T_min and T <= T_max, "
Temperature T (= "   + String(T) + " K) is not
in the allowed range ("   + String(T_min) + " K <= T <= " + String(T_max)
           + " K)
required from medium model \""   + mediumName + "\".
");

        // h = cp_const*(T-T0);
    h = specificEnthalpy_pTX(p,T,X);
    u = cv_const*(T-T0);
    // original equation d = d_const;
    d = if (kT > 1E-20) then d_const * (1+kT*(p-p0)/p0) else d_const;
   // d = d_const * (1+kT*(T-T0)/T0); "this gives large coupled equations"
    R = 0;
    MM = MM_const;
    state.T = T;
    state.p = p;
        annotation (Documentation(info="<HTML>
<p>
This is the most simple incompressible medium model, where
specific enthalpy h and specific internal energy u are only
a function of temperature T and all other provided medium
quantities are assumed to be constant.
</p>
</HTML>"));
  end BaseProperties;

  redeclare function setState_pTX
    "Return thermodynamic state from p, T, and X or Xi"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input Temperature T "Temperature";
    input MassFraction X[:]=reference_X "Mass fractions";
    output ThermodynamicState state "thermodynamic state record";
    annotation(Documentation(info="<html></html>"));
  algorithm
    state := ThermodynamicState(p=p,T=T);
  end setState_pTX;

  redeclare function setState_phX
    "Return thermodynamic state from p, h, and X or Xi"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Specific enthalpy";
    input MassFraction X[:]=reference_X "Mass fractions";
    output ThermodynamicState state "thermodynamic state record";
    annotation(Documentation(info="<html></html>"));
  algorithm
    state := ThermodynamicState(p=p,T=T0+h/cp_const);
  end setState_phX;

  redeclare replaceable function setState_psX
    "Return thermodynamic state from p, s, and X or Xi"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEntropy s "Specific entropy";
    input MassFraction X[:]=reference_X "Mass fractions";
    output ThermodynamicState state "thermodynamic state record";
    annotation(Documentation(info="<html></html>"));
  algorithm
    state := ThermodynamicState(p=p,T=Modelica.Math.exp(s/cp_const + Modelica.Math.log(reference_T)))
      "here the incompressible limit is used, with cp as heat capacity";
  end setState_psX;

  redeclare function setState_dTX
    "Return thermodynamic state from d, T, and X or Xi"
    extends Modelica.Icons.Function;
    input Density d "density";
    input Temperature T "Temperature";
    input MassFraction X[:]=reference_X "Mass fractions";
    output ThermodynamicState state "thermodynamic state record";
    annotation(Documentation(info="<html></html>"));
  algorithm
    assert(false,"pressure can not be computed from temperature and density for an incompressible fluid!");
  end setState_dTX;

      redeclare function extends setSmoothState
    "Return thermodynamic state so that it smoothly approximates: if x > 0 then state_a else state_b"
      algorithm
    state := ThermodynamicState(p=Modelica.Media.Common.smoothStep(
            x, 
            state_a.p, 
            state_b.p, 
            x_small), T=Modelica.Media.Common.smoothStep(
            x,
            state_a.T,
            state_b.T,
            x_small));
      end setSmoothState;

  redeclare function extends dynamicViscosity "Return dynamic viscosity"

  annotation(Documentation(info="<html></html>"));
  algorithm
    eta := eta_const;
  end dynamicViscosity;

  redeclare function extends thermalConductivity "Return thermal conductivity"

    annotation (Documentation(info="<html></html>"));
  algorithm
    lambda := lambda_const;
  end thermalConductivity;

  redeclare function extends pressure "Return pressure"

  annotation(Documentation(info="<html></html>"));
  algorithm
    p := state.p;
  end pressure;

  redeclare function extends temperature "Return temperature"

  annotation(Documentation(info="<html></html>"));
  algorithm
    T := state.T;
  end temperature;

  redeclare function extends density "Return density"

  annotation(Documentation(info="<html></html>"));
  algorithm
    d := d_const;
  end density;

  redeclare function extends specificEnthalpy "Return specific enthalpy"

  annotation(Documentation(info="<html></html>"));
  algorithm
    h := cp_const*(state.T-T0);
  end specificEnthalpy;

  redeclare function extends specificHeatCapacityCp
    "Return specific heat capacity at constant pressure"

    annotation(Documentation(info="<html></html>"));
  algorithm
    cp := cp_const;
  end specificHeatCapacityCp;

  redeclare function extends specificHeatCapacityCv
    "Return specific heat capacity at constant volume"

    annotation(Documentation(info="<html></html>"));
  algorithm
    cv := cv_const;
  end specificHeatCapacityCv;

  redeclare function extends isentropicExponent "Return isentropic exponent"

    annotation(Documentation(info="<html></html>"));
  algorithm
    gamma := cp_const/cv_const;
  end isentropicExponent;

  redeclare function extends velocityOfSound "Return velocity of sound "

    annotation(Documentation(info="<html></html>"));
  algorithm
    a := a_const;
  end velocityOfSound;

  redeclare function specificEnthalpy_pTX
    "Return specific enthalpy from p, T, and X or Xi"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input Temperature T "Temperature";
    input MassFraction X[nX] "Mass fractions";
    output SpecificEnthalpy h "Specific enthalpy";
    annotation(Documentation(info="<html></html>"));
  algorithm
    h := cp_const*(T-T0);
  end specificEnthalpy_pTX;

  redeclare function temperature_phX
    "Return temperature from p, h, and X or Xi"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Specific enthalpy";
    input MassFraction X[nX] "Mass fractions";
    output Temperature T "Temperature";
    annotation(Documentation(info="<html></html>"));
  algorithm
    T := T0 + h/cp_const;
  end temperature_phX;

  redeclare function density_phX "Return density from p, h, and X or Xi"
    extends Modelica.Icons.Function;
    input AbsolutePressure p "Pressure";
    input SpecificEnthalpy h "Specific enthalpy";
    input MassFraction X[nX] "Mass fractions";
    output Density d "density";
    annotation(Documentation(info="<html></html>"));
  algorithm
    d := density(setState_phX(p,h,X));
  end density_phX;

  annotation (Documentation(info="<html>
This medium model is identical to 
<a href=\"Modelica://Modelica.Media.Interfaces.PartialSimpleMedium\">
Modelica.Media.Interfaces.PartialSimpleMedium</a>, but it allows
to define a compressibility of the medium.
This helps breaking algebraic loops, but the system gets stiff.
The compressibility is defined by the constant <code>kT</code>.
If <code>kT=0</code>, then the density is constant. Otherwise,
the density is
<pre>
  rho(p) = rho(p0) * ( 1 + kT * (p-p0)/p0)
</pre>

</html>", revisions="<html>
<ul>
<li>
October 2, 2009, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"));
end PartialSimpleMedium;