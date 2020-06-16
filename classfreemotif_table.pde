/*---------'freeMotif Class'--------*/
class freeMotif_table{

  String motif_name="default";
  //counter variable for scanning / rendering notes
  int noterenderindex;
  // number of notes in freemotif
  int numnotes;
  // Multidimensional array,
  // notearray[<# note in motif>,<attribute #>]
  // { {pitch <diatonic reference>,
  //    start position,
  //    duration,
  //    velocity,
  //    timbre A,
  //    timbre B} }

  /***********REMOVE*****/
  Table notearray_table;
  /***********REMOVE*****/
  // motif position (for iterations relative to first iteration)
  float pos_time=0;
  // MIDI note Tonic index (60= Middle C)
  float pos_tonic=60;
  // Diatonic Offset to shift motif up and down within scale
  float diatonic_offset=0;
  // motif length in time (not number of notes)?
  float motif_length;
  // scales motif in time
  float scale_time=1;
  // scales duration of note durations in motif
  float scale_dur=1;
  // scales diatonic values (-1) is an inversion
  float scale_diatonic=1;

  // Bool; 0=normal direction, 1 motif is reversed
  float tonal_retrograde=0;
  // Bool; 0=normal direction, 1 motif is reversed
  float duration_retrograde=0;
  // Bool; 0=normal direction, 1 motif is reversed
  float position_retrograde=0;
  // Bool; 0=normal direction, 1 motif is reversed
  float velocity_retrograde=0;


  // Fragmentation: index of first note fragment
  int frag_index=0;
  // Fragmentation: number of notes in frag
  int frag_length;
  // index of instrument
  int inst_index=0;

  freeMotif_table(Table classinputmotif_table){
      //notearray_table=classinputmotif_table;

      notearray_table = new Table();

      notearray_table.addColumn("pitch");
      notearray_table.addColumn("time_pos");
      notearray_table.addColumn("duration");
      notearray_table.addColumn("velocity");
      notearray_table.addColumn("timbre1");
      notearray_table.addColumn("timbre2");


      for (int load_scan_iter=0; load_scan_iter<classinputmotif_table.getRowCount(); load_scan_iter++){
            TableRow rowbuffer = classinputmotif_table.getRow(load_scan_iter);
            notearray_table.addRow(rowbuffer);
      }

      println("notearray_table.getFloat(0,pitch)");
      println(notearray_table.getFloat(0,"pitch"));

      println("post 'classinputmotif_table' loading to 'notearray_table'");
      print_mm();

      notearray_table.sort("time_pos");

      numnotes=notearray_table.getRowCount();
      frag_length=numnotes;

      //calculate motif length ()
      motif_length=notearray_table.getFloat((frag_length-1),"time_pos")+notearray_table.getFloat((frag_length-1),"duration");

      // println(motif_name,"motif_length");
      // println(motif_length);
  }

  //Method is called to write motif to score / GUI
  void renderfreemotif(){
      //drawgrid();

      //println(notearray.length);
      //println(notearray[0][0]);
      //println(notearray[0][1]);
      //println(notearray[0][2]);
      //println(notearray[0][3]);
      //println(notearray[0][4]);
      //println(notearray[0][5]);

      // { {pitch <diatonic reference>,
      //    start position,
      //    duration,
      //    velocity,
      //    timbre A,
      //    timbre B} }
      for(int notescan_abspos=frag_index; notescan_abspos<frag_length ; notescan_abspos++){


        /*-------start rendering calcuations--------*/
        noterenderindex = notescan_abspos;

        //factor in 'tonal_retrograde'


        int tablepitch_index;
        if(tonal_retrograde==0){
          tablepitch_index = notescan_abspos;
        } else {
          tablepitch_index = frag_length-1-notescan_abspos;
        }

        //factor in 'duration-retrograde'
        int tabledur_index = notescan_abspos;
        if(duration_retrograde==0){
          tabledur_index = notescan_abspos;
        } else {
          tabledur_index = frag_length-1-notescan_abspos;
        }

        //relative position of note in riff
        float tablepos_fromindex;
        float fragmentationoffset = notearray_table.getFloat(frag_index, "time_pos");
        if(position_retrograde==0){
          tablepos_fromindex = notearray_table.getFloat(notescan_abspos, "time_pos");
        } else {
          if(notescan_abspos==0)
          {
            tablepos_fromindex = 0;
          } else{
            tablepos_fromindex = motif_length-notearray_table.getFloat((frag_length-notescan_abspos)%frag_length, "time_pos");
          }
        }

        int tablevel_index;
        if(velocity_retrograde==0){
          tablevel_index = notescan_abspos;
        } else {
          tablevel_index = frag_length-1-notescan_abspos;
        }

        //calculate overall diatonic degree
        float diatonic_degree = (notearray_table.getFloat(tablepitch_index, "pitch"))*(scale_diatonic)+diatonic_offset;

        float output_pitch = return_diaton(diatonic_degree,pos_tonic);

        //absolute time (relative to score)
        float output_pos = (global_time_render_offset+pos_time+tablepos_fromindex*scale_time)-fragmentationoffset;

        float output_dur = notearray_table.getFloat(tabledur_index, "duration")*scale_dur;
        float output_vel = notearray_table.getFloat(tablevel_index, "velocity");
        float output_timb1 = notearray_table.getFloat(notescan_abspos, "timbre1");
        float output_timb2 = notearray_table.getFloat(notescan_abspos, "timbre2");
        /*-------end rendering calcuations--------*/


        if(notescan_abspos==frag_index)
        {
          addGUIcom(output_pitch,output_pos,inst_index,motif_name);
        }



        //draw notes in GUI
        drawnote(output_pitch,
                output_pos,
                output_dur,
                output_vel,
                output_timb1,
                output_timb2,
                inst_index);

        //add notes to MIDI score
        //score.addNote(startTime,
        //              channel,
        //              instrument,
        //              pitch,
        //              dynamic,
        //              duration,
        //              articulation,
        //               pan);
        score.addNote(output_pos,
                      inst_index,
                      inst_cata[inst_index],
                      output_pitch,
                      output_vel,
                      output_dur,
                      127,
                      64);


        //add noteOffs
        score.addNote(output_pos+output_dur,
                      inst_index,
                      inst_cata[inst_index],
                      output_pitch,
                      0,
                      output_dur,
                      127,
                      64);
        /******************/

        // end 'renderfreemotif' method
      }

        //
      /******************/
      print("motif_name ");
      println(motif_name);
      print_mm();
      /******************/
  }

  void reset_properties(){
    // // motif position (for iterations relative to first iteration)
    // pos_time=0;
    // MIDI note Tonic index (60= Middle C)
    pos_tonic=60;
    // Diatonic Offset to shift motif up and down within scale
    diatonic_offset=0;
    // scales motif in time
    scale_time=1;
    // scales duration of note durations in motif
    scale_dur=1;
    // scales diatonic values (-1) is an inversion
    scale_diatonic=1;

    // Bool; 0=normal direction, 1 motif is reversed
    tonal_retrograde=0;
    // Bool; 0=normal direction, 1 motif is reversed
    duration_retrograde=0;
    // Bool; 0=normal direction, 1 motif is reversed
    position_retrograde=0;
    // Bool; 0=normal direction, 1 motif is reversed
    velocity_retrograde=0;


    // Fragmentation: index of first note fragment
    frag_index=0;
    // Fragmentation: number of notes in frag
    frag_length=numnotes;
    // index of instrument
  }

  void concat_mm(Table appendtable){
        //1. scanrows of new tabledur_index
        Table buffertable = new Table();
        int buffertablerowcount = appendtable.getRowCount();
        buffertable.addColumn("pitch");
        buffertable.addColumn("time_pos");
        buffertable.addColumn("duration");
        buffertable.addColumn("velocity");
        buffertable.addColumn("timbre1");
        buffertable.addColumn("timbre2");

        for (int rowiter=0; rowiter<buffertablerowcount; rowiter++) {
            buffertable.addRow(appendtable.getRow(rowiter));
        }


        println("@after Table buffertable = appendtable;");


        println(buffertablerowcount);
        println("buffertablerowcount");

        // for (TableRow row : buffertable.rows()) {
        //
        //     float time_pos_shifted=row.getFloat("time_pos")+motif_length;
        //     row.setFloat("time_pos",time_pos_shifted);
        //     notearray_table.addRow(row);
        //     //println("@after notearray_table.addRow(row);");
        // }

        for (int rowiter=0; rowiter<buffertablerowcount; rowiter++) {

            TableRow row = buffertable.getRow(rowiter);

            float time_pos_shifted=row.getFloat("time_pos")+motif_length;
            println(time_pos_shifted);
            println("time_pos_shifted");
            row.setFloat("time_pos",time_pos_shifted);
            notearray_table.addRow(row);
        }

        // println("print_mm():concat_mm");
        // //print_mm();

        numnotes=notearray_table.getRowCount();
        frag_length=numnotes;
        motif_length=notearray_table.getFloat((frag_length-1),"time_pos")+notearray_table.getFloat((frag_length-1),"duration");
        println(frag_length);

        notearray_table.sort("time_pos");
      }

  void prepend_mm(Table appendtable){
                //Make Buffer Table
                Table buffertable = new Table();
                int buffertablerowcount = appendtable.getRowCount();
                buffertable.addColumn("pitch");
                buffertable.addColumn("time_pos");
                buffertable.addColumn("duration");
                buffertable.addColumn("velocity");
                buffertable.addColumn("timbre1");
                buffertable.addColumn("timbre2");
                for (int rowiter=0; rowiter<buffertablerowcount; rowiter++) {
                    buffertable.addRow(appendtable.getRow(rowiter));
                }

                //time length of prepend_mm
                float prepend_mm_length = buffertable.getFloat((buffertablerowcount-1),"time_pos")
                                         +buffertable.getFloat(((buffertablerowcount-1)),"duration");

                println("prepend_mm_length");
                println(prepend_mm_length);


                // scan: add prepend_mm_length to all existing notes
                for (int rowiter=0; rowiter<numnotes; rowiter++) {
                      //load buffer row
                      TableRow row = notearray_table.getRow(rowiter);

                      //calculate time shift
                      float time_pos_shifted=row.getFloat("time_pos")+prepend_mm_length;

                      //write to note
                      notearray_table.setFloat(rowiter,"time_pos",time_pos_shifted);
                }

                //
                for (int rowiter=0; rowiter<buffertablerowcount; rowiter++) {
                    //load buffer row
                    TableRow row = buffertable.getRow(rowiter);
                    // //calculate timeshift ( )
                    // float time_pos_shifted=row.getFloat("time_pos")+motif_length;
                    // println(time_pos_shifted);
                    // println("time_pos_shifted");
                    // row.setFloat("time_pos",time_pos_shifted);
                    notearray_table.addRow(row);
                }

                //sort table

                numnotes=notearray_table.getRowCount();
                frag_length=numnotes;
                motif_length=notearray_table.getFloat((frag_length-1),"time_pos")+notearray_table.getFloat((frag_length-1),"duration");
                println(frag_length);

                //notearray_table.setFloat(9,"time_pos",0.5);
                notearray_table.sort("time_pos");
                println("print_mm: prepend_mm");
                print_mm();
}

  void render_frag(){

            //buffer table for fragment
            Table des_frag_table = new Table();
            des_frag_table.addColumn("pitch");
            des_frag_table.addColumn("time_pos");
            des_frag_table.addColumn("duration");
            des_frag_table.addColumn("velocity");
            des_frag_table.addColumn("timbre1");
            des_frag_table.addColumn("timbre2");

            float frag_time_offset = notearray_table.getFloat(frag_index,"time_pos");

            //
            for(int notescan_abspos=frag_index; notescan_abspos<frag_length ; notescan_abspos++){
                TableRow row = notearray_table.getRow(notescan_abspos);
                row.setFloat("time_pos",(row.getFloat("time_pos")-frag_time_offset));
                des_frag_table.addRow(row);

            }

            //clear old scan and scan in fragment
            notearray_table.clearRows();
            for (TableRow row : des_frag_table.rows()) {
                notearray_table.addRow(row);
            }

            print_mm();

            numnotes=notearray_table.getRowCount();
            frag_index=0;
            frag_length=numnotes;
            println(frag_length);

            notearray_table.sort("time_pos");
          }

  void print_mm(){
        //1. scanrows of new tabledur_index
        //2. Add rows onto notearray_table
        //3. sort new table?? (shouldn't need to )

        for (int rowcounter=0; rowcounter<notearray_table.getRowCount(); rowcounter++) {
            TableRow row = notearray_table.getRow(rowcounter);

            println("in print_mm loop");
            print("row counter:", rowcounter, " ");
            print("pitch:",row.getString("pitch"), " ");
            print("time_pos:",row.getString("time_pos"), " ");
            print("duration:",row.getString("duration"), " ");
            print("velocity:",row.getString("velocity"), " ");
            print("timbre1:",row.getString("timbre1"), " ");
            print("timebre2:",row.getString("timbre2"), " ");
            println("");
        }
  }

}
