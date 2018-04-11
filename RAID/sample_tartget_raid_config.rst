## SAMPLE INPUT DATA:

# Sample 1: Auto create without physical_disks and 1 array. Let change raid_level = 0 or 5 or 6 or 10 or 50 or 60 for each case.

.. code_block:: init

	{
	  "logical_disks":
	    [
	      {
		"size_gb": 1000,
		"raid_level": "1"
	      }
	    ]
	}


# Sample 2: Auto create without physical_disks and 2 array.

.. code_block:: init

	{
	  "logical_disks":
	    [
	      {
		"size_gb": 1000,
		"raid_level": "0"
	      },
	      {
		"size_gb": 1000,
		"raid_level": "1"
	      }
	    ]
	}

# Sample 3:

.. code_block:: init

	{
	  "logical_disks":
	    [
	      {
		"size_gb": 1000,
		"raid_level": "1",
                "physical_disks": [
                                   "0",
                                   "1"
                                  ]
	      }
	    ]
	}

# Sample 4:

.. code_block:: init

	{
	  "logical_disks":
	    [
	      {
		"size_gb": 1000,
		"raid_level": "1",
                "physical_disks": [
                                   "0",
                                   "1"
                                  ]
	      },
	      {
		"size_gb": 1000,
		"raid_level": "1",
                "physical_disks": [
                                   "2",
                                   "3"
                                  ]
	      }
	    ]
	}

Notes::
   
   - Don't need to add physical_disks in RAID 10, 50 and 60. It will auto create into BM via iRMC
     driver.
	
