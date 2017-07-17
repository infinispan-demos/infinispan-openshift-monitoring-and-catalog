package org.workspace7.moviestore;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import org.infinispan.client.hotrod.RemoteCache;
import org.infinispan.client.hotrod.RemoteCacheManager;
import org.infinispan.spring.starter.remote.InfinispanRemoteCacheCustomizer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@SpringBootApplication
public class MonitoringDemo {

    @Configuration
    public static class HotRodConfiguration {

        @Value("#{environment.SERVER_LIST}")
        private String serverList;

        @Value("#{environment.USERNAME}")
        private String username;

        @Value("#{environment.PASSWORD}")
        private String password;

        @Bean
        public InfinispanRemoteCacheCustomizer customizer() {
            return b -> b
                  .addServers(serverList)
                  //.security().authentication().username(username).password(password.toCharArray()).enable()
                  ;
        }
        public static void main(String... args) throws InterruptedException {
            ConfigurableApplicationContext context = SpringApplication.run(MonitoringDemo.class, args);

            RemoteCacheManager remoteCacheManager = context.getBean(RemoteCacheManager.class);
            RemoteCache<String, String> cache = remoteCacheManager.getCache();

            cache.put(Long.toString(System.currentTimeMillis()), "Yeah, Infinispan is cool!");

            AtomicInteger numOfEntries = new AtomicInteger();
            cache.entrySet().forEach(e -> {
                System.out.println(numOfEntries.getAndIncrement() + " " + e);
            });
            System.err.println("Toal entries: " + numOfEntries.get());

            TimeUnit.HOURS.sleep(1);
        }

    }
}
