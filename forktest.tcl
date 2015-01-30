foreach title {apple banana orange} {
   fork_task title {
      puts $title
   }
}
wait_for_forked title

