/* **************************************************************************************************
*                                        ArrayX Include File                                  |v1.17|
* Defines and natives for ArrayX use.                           Requirements:
* Place in scripting/includes.                                  - ArrayX.dll - Dynamic Array Module
*
* Be careful with editing:
*   Dynamic arrays are extremely efficient, but will allocate and use memory directly, this can be
*   very dangerous if an infinite loop starts. BE CAREFUL.
*
* Important information:
*   This module implements error handling on multiple levels, preventing uninitialized arrays and
*   indexes from being used. This checking can be disabled on every function that warrants it.
*   This will allow the coder to set arrays without knowing whether they are initialized and the
*   same applies for using 'get' on unset indexes.
*
* What is "disable_check"
*   To disable checking use the last parameter with a value set to 1. If you do not use every
*   parameter, on say:
*       arraysize(arrayid, start = 0, stop = -1,            disable_check = 0)
*   You should let Small fill in default values by using one of the following:
*       arraysize(arrayid, _, _, 1)
*       arraysize(arrayid, .disable_check = 1)
*   The first works by filling in default values where a _ is, and the second uses a named
*   parameter. Both methods will work the same.
*
* What is "reserve_id"
*   Like disable_check, this bypasses another form of error prevention. When creating a new array
*   the array is provided an id that is not used.
*
*   However, if multiple plugins would like to use the same id or for some reason it is not feasible
*   to pass the array id to every function that needs it, it may be necessary to use an arrayid and
*   still be able to 'create' it in any function that needs it.
*
*   For this reason, the reserve_id parameter will force an id provided to be used.
*   Any existing array will not be deleted.
************************************************************************************************** */

/////////////////////////////////////////////////////////////////////////////////////////////////////

#if defined _arrayx_included
    #endinput
#endif
#define _arrayx_included

/////////////////////////////////////////////////////////////////////////////////////////////////////

/**\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ \**/
//   Arrays by Twilight Suzuka & Anpheus:                           Dynamic arrays using indices
/**\ \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ \**/
// Note: Defines are used to unify interface.

/**\ =========================================================================================== \**/
//                                   Array Creation and Management
/**\ =========================================================================================== \**/

//Create, clear, or delete an array. 
native array_create (arrayid = 0,                                               reserve_id = 0      );
native array_clear  (arrayid);
native array_delete (arrayid);
#define new_array       array_create
#define clear_array     array_clear
#define delete_array    array_delete

//Saves and load an array to or from filename. array_load acts like new_array.
native array_save(arrayid, filename[],                                          disable_check = 0   );
native array_load(filename[], arrayid = 0,                                      reserve_id = 0      );

//Loads a saved array and copies it in more readable form.
native array_save_ascii(inputarrayfile[], outputfile[]);

// Returns the number of _arrayids_ in use in a range.
native array_count(start = 0, stop = -1);

// Returns the amount of memory used by an array in bytes
native array_memory(arrayid,                                disable_check = 0);

/**\ =========================================================================================== \**/
//                                          Array Editing
/**\ =========================================================================================== \**/

native array_remove             (arrayid, index,                                disable_check = 0   );
#define remove_cell array_remove

native          array_set_int   (arrayid, index, value,                         disable_check = 0   );
native          array_get_int   (arrayid, index,                                disable_check = 0   );

native          array_set_float (arrayid, index, Float:value,                   disable_check = 0   );
native Float:   array_get_float (arrayid, index,                                disable_check = 0   );

native          array_set_string(arrayid, index, value[],                       disable_check = 0   );
native          array_get_string(arrayid, index, ret_val[], len,                disable_check = 0   );

native          array_set_vector(array, index, Float:vector[3],                 disable_check = 0   );
native          array_get_vector(array, index, Float:vector[3],                 disable_check = 0   );

#define set_cell_int        array_set_int
#define get_cell_int        array_get_int
#define set_cell_float      array_set_float
#define get_cell_float      array_get_float
#define set_cell_string     array_set_string
#define get_cell_string     array_get_string
#define set_cell_vector     array_set_vector
#define get_cell_vector     array_get_vector

/**\ =========================================================================================== \**/
//                                         Array Searching
/**\ =========================================================================================== \**/

//Counts the number of elements in an array between start and stop including the starting and stop.
native array_size       (array, start = 0, stop = -1,                           disable_check = 0   );

//Returns the nth index in an array.
native array_get_nth    (array, n, start = 0,                                   disable_check = 0   );

//Returns 1 if index is empty or filled.
native array_isempty    (array, index,                                          disable_check = 0   );
native array_isfilled   (array, index,                                          disable_check = 0   );

//Returns first filled index (check success)
native array_next   (array, index =  0, &success = 0,                           disable_check = 0   );
native array_first  (array, index =  0, &success = 0,                           disable_check = 0   );
native array_prev   (array, index = -1, &success = 0,                           disable_check = 0   );
native array_last   (array, index = -1, &success = 0,                           disable_check = 0   );

//Returns first empty index (check success)
native array_nextempty  (array, index =  0, &success = 0,                       disable_check = 0   );
native array_firstempty (array, index =  0, &success = 0,                       disable_check = 0   );
native array_prevempty  (array, index = -1, &success = 0,                       disable_check = 0   );
native array_lastempty  (array, index = -1, &success = 0,                       disable_check = 0   );

/////////////////////////////////////////////////////////////////////////////////////////////////////

/**\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ \**/
//   Keytables by Anpheus:                                          Dynamic arrays using strings
/**\ \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ \**/


/**\ =========================================================================================== \**/
//                                 Keytable Creation and Management
/**\ =========================================================================================== \**/

native keytable_create  (startid = 0,                                       reserveid = 0);
native keytable_delete  (keytable);
native keytable_clear   (keytable);

native keytable_save(keytable, filename[],                                  disable_check = 0);
native keytable_load(filename[], keytable = 0,                              reserve_id = 0);

native keytable_save_ascii(inputkeytable[], outputkeytable[]);

native keytable_memory(keytable,                                            disable_check = 0);

/**\ =========================================================================================== \**/
//                                         Keytable Editing
/**\ =========================================================================================== \**/

native keytable_remove(keytable, const key[]);

native keytable_set_int(keytable, const key[], value,                       disable_check = 0);
native keytable_get_int(keytable, const key[],                              disable_check = 0);
native keytable_set_string(keytable, const key[], value[],                  disable_check = 0);
native keytable_get_string(keytable, const key[], ret_value[], ret_length,  disable_check = 0);

native keytable_set_vector(keytable, const key[], Float:value[3],           disable_check = 0);
native keytable_get_vector(keytable, const key[], Float:value[3],           disable_check = 0);


native          keytable_set_float(keytable, const key[], Float:value,      disable_check = 0);
native Float:   keytable_get_float(keytable, const key[],                   disable_check = 0);

/**\ =========================================================================================== \**/
//                                        Keytable Searching
/**\ =========================================================================================== \**/

native keytable_isempty (keytable, const key[],                             disable_check = 0);
native keytable_isfilled(keytable, const key[],                             disable_check = 0);

//Return string will be "dne" if an error occured.
//It is possible to pass the same key to key[] and retr_string[], the key will be overwritten.
native keytable_next    (keytable, const key[], retr_string[], retr_length, disable_check = 0);
native keytable_first   (keytable, const key[], retr_string[], retr_length, disable_check = 0);
native keytable_prev    (keytable, const key[], retr_string[], retr_length, disable_check = 0);
native keytable_last    (keytable, const key[], retr_string[], retr_length, disable_check = 0);

/////////////////////////////////////////////////////////////////////////////////////////////////////

/**\ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ \**/
//   Hashtables by Anpheus:                                  Dynamic arrays using hashed strings
/**\ \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ \**/


/**\ =========================================================================================== \**/
//                                Hashtable Creation and Management
/**\ =========================================================================================== \**/

native hashtable_create (                                          startid = 0, reserveid = 0);
native hashtable_delete (hashtable);
native hashtable_clear  (hashtable);

native hashtable_save(hashtable, filename[],                                disable_check = 0);
native hashtable_load(filename[],                               hashtable = 0, reserve_id = 0);

native hashtable_memory(hashtable,                                          disable_check = 0);

/**\ =========================================================================================== \**/
//                                        Hashtable Editing
/**\ =========================================================================================== \**/

native hashtable_remove(hashtable, key[]);

native hashtable_set_str(hashtable, const key[], value[],                   disable_check = 0);
native hashtable_get_str(hashtable, const key[], ret_value[], ret_length,   disable_check = 0);

native hashtable_set_vec(hashtable, const key[], Float:value[3],            disable_check = 0);
native hashtable_get_vec(hashtable, const key[], Float:value[3],            disable_check = 0);

native hashtable_set_int(hashtable, const key[], value,                     disable_check = 0);
native hashtable_get_int(hashtable, const key[],                            disable_check = 0);

native          hashtable_set_float(hashtable, const key[], Float:value,    disable_check = 0);
native Float:   hashtable_get_float(hashtable, const key[],                 disable_check = 0);

/**\ =========================================================================================== \**/
//                                       Hashtable Searching
/**\ =========================================================================================== \**/

//This function is very important: It returns the first valid key in the array. This key does
//not have to start with '\0', either. To search from the beginning of a hashtable, use this.
native hashtable_firstkey(hashtable, retr_string[], retr_length,            disable_check = 0);

native hashtable_isempty (hashtable, const key[],                           disable_check = 0);
native hashtable_isfilled(hashtable, const key[],                           disable_check = 0);

//Return string will be "dne" if an error occured.
//It is possible to pass the same key to key[] and retr_string[], the key will be overwritten.
//As well, 1 (true) is returned when succesful, 0 (false) when not.
native hashtable_next  (hashtable, const key[], retr_string[], retr_length, disable_check = 0);
native hashtable_first (hashtable, const key[], retr_string[], retr_length, disable_check = 0);
native hashtable_prev  (hashtable, const key[], retr_string[], retr_length, disable_check = 0);
native hashtable_last  (hashtable, const key[], retr_string[], retr_length, disable_check = 0);

/////////////////////////////////////////////////////////////////////////////////////////////////////