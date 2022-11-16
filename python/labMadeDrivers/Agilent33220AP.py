from typing import Any, Union

import numpy as np

from qcodes.instrument import VisaInstrument
from qcodes.validators import Enum, Numbers


class Agilent33220A(VisaInstrument):
    """
    This is a QCoDeS driver for the Agilent 33220A signal generator.
    
    This is an adapted version of the QCoDeS driver for the Agilent E8267C driver.
    """

    def __init__(self, name: str, address: str, **kwargs: Any) -> None:
        super().__init__(name, address, terminator="\n", **kwargs)
        # general commands
        self.add_parameter(
            name="frequency",
            label="Frequency",
            unit="Hz",
            get_cmd="FREQ?",
            set_cmd="FREQ {}",
            get_parser=float,
            vals=Numbers(min_value=1, max_value=20e6),
        )
        self.add_parameter(
            name="freq_mode",
            label="Frequency mode",
            set_cmd="FREQ:MODE {}",
            get_cmd="FREQ:MODE?",
            vals=Enum("FIX", "CW", "SWE", "LIST"),
        )
        self.add_parameter(
            name="phase",
            label="Phase",
            unit="deg",
            get_cmd="PHAS?",
            set_cmd="PHAS {}",
            get_parser=self.rad_to_deg,
            set_parser=self.deg_to_rad,
            vals=Numbers(min_value=-180, max_value=179),
        )
        self.add_parameter(
            name="apply",
            label="Apply function",
            get_cmd="APPL?",
            set_cmd="APPL {}",
            vals=Enum("SIN", "SQU", "RAMP", "NRAM", "TRI", "NOIS", "USER"),
        )
        self.add_parameter(
            name="am_mode",
            label="Amplitude modulation mode",
            get_cmd="AM:STAT?",
            set_cmd="AM:STAT {}",
            val_mapping={"OFF": 0, "ON": 1},
        )
        self.add_parameter(
            name="am_func",
            label="Amplitude modulation function type",
            get_cmd="AM:INT:FUNC?",
            set_cmd="AM:INT:FUNC {}",
            vals=Enum("SIN", "SQU", "RAMP", "NRAM", "TRI", "NOIS", "USER"),
        )
        self.add_parameter(
            name="burst_mode",
            label="Burst mode",
            get_cmd="BURS:MODE?",
            set_cmd="BURS:MODE {}",
            vals=Enum("GAT", "TRIG"),
        )
        
        # reset values after each reconnect
        self.connect_message()
        self.add_function("reset", call_cmd="*RST")

    # functions to convert between rad and deg
    @staticmethod
    def deg_to_rad(
        angle_deg: Union[float, str, np.floating, np.integer]
    ) -> "np.floating[Any]":
        return np.deg2rad(float(angle_deg))

    @staticmethod
    def rad_to_deg(
        angle_rad: Union[float, str, np.floating, np.integer]
    ) -> "np.floating[Any]":
        return np.rad2deg(float(angle_rad))
