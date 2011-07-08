''' 
Running a Simulation
====================

This module provides an example that illustrates the
use of the python to run a Modelica simulation.

The package ``buildingspy.simulate`` provides the class
``Simulator.py`` that can be used to automate running simulations.
For example, to run the model 
``Buildings.Controls.Continuous.Examples.PIDHysteresis.mo``
with controller parameters ``con.eOn = 1`` and ``con.eOn = 5``, use
the following commands:

.. literalinclude:: ../../buildingspy/examples/dymola/runSimulation.py

This will run the two test cases and store the results in the directories
``case1`` and ``case2``



Plotting of Time Series
=======================

This module provides an example that illustrates the
use of the python to plot results from a Dymola simulation.

The file ``plotResult.py`` illustrates how to plot results from a
Dymola output file. To run the example, proceed as follows:

 1. Open a terminal or dos-shell.
 2. Set the PYTHONPATH environment variables to the 
    directory ```bie/BuildingsPy/buildingspy```, such as

    .. code-block:: bash

       export PYTHONPATH=${PYTHONPATH}:../..

    where the directory ``../..`` contains the subdirectory ``buildingspy``
 3. Type

    .. code-block:: bash

       python plotResult.py

This will execute the script ``plotResult.py``, which contains
the following instructions:

.. literalinclude:: ../../buildingspy/examples/dymola/plotResult.py

The script generates the following plot:

.. image:: ../../buildingspy/examples/dymola/plot.png
   :scale: 100 %
   :alt: Plot generated by ``plotResult.py``
   :align: center



'''

