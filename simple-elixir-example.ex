defmodule SpawnExample do
  send self(), {:hello, "world"}
  receive do
    {:hello, msg} -> msg
    {:world, msg} -> "won't match"
  end
  
  spawn(fn -> loop() end)
  def loop() do
    receive do
      message -> IO.puts "received #{message}"; 
      loop();
    end
  end

  def resolveAfter2Seconds() do
    Process.sleep(2000);
    IO.inspect("slow promise is done");
    send self(), "slow"
  end
  def resolveAfter1Second() do
    Process.sleep(1000);

    IO.inspect("fast promise is done");
    send self(), "fast"
  end
  def sequentialStart() do
    IO.inspect("==SEQUENTIAL START==");
    slow = resolveAfter2Seconds();
    IO.inspect(slow); ## 2. this runs 2 seconds after 1.

    fast = resolveAfter1Second();
    IO.inspect(fast); ## 3. this runs 3 seconds after 1.
  end
  def concurrentStart() do
    IO.inspect('==CONCURRENT START with await==');
    slow = spawn(fn -> resolveAfter2Seconds() end; // starts timer immediately
    fast = spawn(fn -> resolveAfter1Second()  end; // starts timer immediately
  end

end
