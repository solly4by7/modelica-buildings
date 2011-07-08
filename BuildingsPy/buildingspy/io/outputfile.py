#!/usr/bin/env python
from buildingspy.io.dymola.DyMat import DymolaMat

class Reader:
    """Open the file *fileName* and parse its content.

    :param fileName: The name of the file.
    :param format: The file format. Currently, the only supported 
                   value is ``dymola``.

    This class reads ``*.mat`` files that were generated by Dymola
    or OpenModelica.

    """

    def __init__(self, fileName, format):
        if format != "dymola":
            raise ValueError('Argument "format" needs to be set to "dymola".')

        self.fileName = fileName
        self.__data__ = DymolaMat(fileName)
        
    def values(self, varName):
        '''Get the time and data series.

        :param varName: The name of the variable.
        :return: An array where the first column is time and the second
                 column is the data series.

        Usage: Type
           >>> from buildingspy.io.outputfile import Reader
           >>> r=Reader("PlotDemo.mat", "dymola")
           >>> (time, fanPower) = r.values('fan.PEle')
        '''
        d = self.__data__.data(varName)
        a, aname, tmp = self.__data__.abscissa(varName)
        return a, d
    
    def integral(self, varName):
        '''Get the integral of the data series.

        :param varName: The name of the variable.
        :return: The integral of *varName*.

        This function returns :math:`\int_{t_0}^{t_1} x(s) \, ds`, where
        :math:`t_0` is the start time and :math:`t_1` the final time of the data
        series :math:`x(\cdot)`, and :math:`x(\cdot)` are the data values
        of the variable *varName*
          
        
        Usage: Type
           >>> from buildingspy.io.outputfile import Reader
           >>> r=Reader("PlotDemo.mat", "dymola")
           >>> fanEnergy = r.integral('fan.PEle')
        '''
        (t, v)=self.values(varName)
        val=0.0;
        for i, value in enumerate(t[0:len(t)-1]):
            val = val + (t[i+1]-t[i]) * (v[i+1]+v[i])/2.0
        return val

    def mean(self, varName):
        '''Get the mean of the data series.

        :param varName: The name of the variable.
        :return: The mean value of *varName*.

        This function returns 

        .. math::
           
           \\frac{1}{t_1-t_0} \, \int_{t_0}^{t_1} x(s) \, ds, 
         
        where :math:`t_0` is the start time and :math:`t_1` the final time of the data
        series :math:`x(\cdot)`, and :math:`x(\cdot)` are the data values
        of the variable *varName*
          
        
        Usage: Type
           >>> from buildingspy.io.outputfile import Reader
           >>> r=Reader("PlotDemo.mat", "dymola")
           >>> fanEnergy = r.mean('fan.PEle')
        '''
        (t, v)=self.values(varName)
        r = self.integral(varName)/(max(t)-min(t))
        return r

    def min(self, varName):
        '''Get the minimum of the data series.

        :param varName: The name of the variable.
        :return: The minimum value of *varName*.

        This function returns :math:`\min \{x_k\}_{k=0}^{N-1}`, where
        :math:`\{x_k\}_{k=0}^{N-1}` are the values of the variable *varName*
        
        Usage: Type
           >>> from buildingspy.io.outputfile import Reader
           >>> r=Reader("PlotDemo.mat", "dymola")
           >>> fanEnergy = r.min('fan.PEle')
        '''
        (t, v)=self.values(varName)
        return min(v)

    def max(self, varName):
        '''Get the maximum of the data series.

        :param varName: The name of the variable.
        :return: The maximum value of *varName*.

        This function returns :math:`\max \{x_k\}_{k=0}^{N-1}`, where
        :math:`\{x_k\}_{k=0}^{N-1}` are the values of the variable *varName*
        
        Usage: Type
           >>> from buildingspy.io.outputfile import Reader
           >>> r=Reader("PlotDemo.mat", "dymola")
           >>> fanEnergy = r.max('fan.PEle')
        '''
        (t, v)=self.values(varName)
        return max(v)
